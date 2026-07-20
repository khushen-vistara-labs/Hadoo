import * as FileSystem from "expo-file-system";

import {
  findDownloadForTrack,
  useDownloadStore,
  type DownloadedTrack,
} from "@/modules/downloads/downloadStore";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { usePlayerStore } from "@/modules/player/playerStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { buildCanonicalTrackKey, isStreamExpired } from "@/modules/sources/sourceUtils";
import { logger } from "@/services/logger";
import type { StreamResult, Track } from "@/types/track";

export type DownloadBatchProgress = {
  total: number;
  completed: number;
  downloaded: number;
  skipped: number;
  failed: number;
};

export type DownloadBatchResult = DownloadBatchProgress & {
  failures: { track: Track; error: unknown }[];
};

const DOWNLOAD_DIRECTORY = FileSystem.documentDirectory
  ? `${FileSystem.documentDirectory}downloads/`
  : undefined;

const activeTasks = new Map<string, FileSystem.DownloadResumable>();
const activePromises = new Map<string, Promise<DownloadedTrack>>();
const cancelledTrackIds = new Set<string>();
const pendingDownloadKeys: string[] = [];
const queuedJobs = new Map<
  string,
  {
    track: Track;
    resolve: (download: DownloadedTrack) => void;
    reject: (error: unknown) => void;
  }
>();
const MAX_CONCURRENT_DOWNLOADS = 2;
let runningDownloadCount = 0;

const withoutManagedDownloadFile = (track: Track): Track => {
  if (!DOWNLOAD_DIRECTORY || !track.fileUrl?.startsWith(DOWNLOAD_DIRECTORY)) {
    return track;
  }

  return {
    ...track,
    fileUrl: undefined,
    streamUrl: track.streamUrl?.startsWith(DOWNLOAD_DIRECTORY) ? undefined : track.streamUrl,
    streamExpiresAt: track.streamUrl?.startsWith(DOWNLOAD_DIRECTORY) ? undefined : track.streamExpiresAt,
  };
};

const hashString = (value: string) => {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(36);
};

const extensionForStream = (stream: StreamResult) => {
  const mimeType = stream.mimeType?.toLowerCase() ?? "";
  if (mimeType.includes("audio/mp4") || mimeType.includes("audio/x-m4a")) {
    return "m4a";
  }
  if (mimeType.includes("audio/webm")) {
    return "webm";
  }
  if (mimeType.includes("audio/mpeg")) {
    return "mp3";
  }
  if (mimeType.includes("audio/ogg")) {
    return "ogg";
  }

  const format = stream.format?.toLowerCase().replace(/[^a-z0-9]/g, "");
  if (format && format.length >= 2 && format.length <= 5) {
    return format;
  }

  const pathExtension = stream.url.split(/[?#]/)[0]?.match(/\.([a-zA-Z0-9]{2,5})$/)?.[1];
  return pathExtension?.toLowerCase() ?? "audio";
};

const resolveStream = async (track: Track) => {
  const canonicalKey = buildCanonicalTrackKey(track);
  const player = usePlayerStore.getState();
  const resolvedPlayerTrack = [player.currentTrack, ...player.queue].find(
    (candidate) => candidate && buildCanonicalTrackKey(candidate) === canonicalKey,
  );
  const hasUsableTrackStream =
    track.streamUrl?.startsWith("http") && !isStreamExpired({ expiresAt: track.streamExpiresAt });
  const streamTrack = hasUsableTrackStream ? track : resolvedPlayerTrack;

  if (
    streamTrack?.streamUrl?.startsWith("http") &&
    !isStreamExpired({ expiresAt: streamTrack.streamExpiresAt })
  ) {
    return {
      url: streamTrack.streamUrl,
      headers: streamTrack.streamHeaders,
      quality: streamTrack.quality ?? "unknown",
      format: streamTrack.streamFormat,
      mimeType: streamTrack.streamMimeType,
      expiresAt: streamTrack.streamExpiresAt,
      resolvedTrack: streamTrack,
    } satisfies StreamResult;
  }

  return sourceRegistry.getStreamUrl(
    withoutManagedDownloadFile(track),
    useSettingsStore.getState().audioQuality,
  );
};

const performDownload = async (track: Track): Promise<DownloadedTrack> => {
  if (!DOWNLOAD_DIRECTORY) {
    throw new Error("Downloads are not available on this device.");
  }

  const store = useDownloadStore.getState();
  const existing = findDownloadForTrack(track, store.downloads);
  if (existing) {
    const info = await FileSystem.getInfoAsync(existing.fileUri);
    if (info.exists && !info.isDirectory) {
      store.clearTask(track.id);
      return existing;
    }
    store.removeDownloadRecord(existing.id);
  }

  store.setTask(track.id, {
    track,
    status: "resolving",
    progress: 0,
    bytesWritten: 0,
  });

  let destination: string | undefined;

  try {
    const stream = await resolveStream(track);
    if (cancelledTrackIds.has(track.id)) {
      throw new Error("Download cancelled.");
    }
    await FileSystem.makeDirectoryAsync(DOWNLOAD_DIRECTORY, { intermediates: true });
    destination = `${DOWNLOAD_DIRECTORY}${hashString(buildCanonicalTrackKey(track))}.${extensionForStream(stream)}`;
    await FileSystem.deleteAsync(destination, { idempotent: true });

    let lastProgressUpdate = 0;
    const download = FileSystem.createDownloadResumable(
      stream.url,
      destination,
      { headers: stream.headers },
      ({ totalBytesExpectedToWrite, totalBytesWritten }) => {
        const now = Date.now();
        if (now - lastProgressUpdate < 120 && totalBytesWritten < totalBytesExpectedToWrite) {
          return;
        }
        lastProgressUpdate = now;
        const hasKnownTotal = totalBytesExpectedToWrite > 0;
        useDownloadStore.getState().setTask(track.id, {
          track,
          status: "downloading",
          progress: hasKnownTotal ? Math.min(totalBytesWritten / totalBytesExpectedToWrite, 1) : 0,
          bytesWritten: totalBytesWritten,
          totalBytes: hasKnownTotal ? totalBytesExpectedToWrite : undefined,
        });
      },
    );

    activeTasks.set(track.id, download);
    useDownloadStore.getState().setTask(track.id, {
      track,
      status: "downloading",
      progress: 0,
      bytesWritten: 0,
    });

    const result = await download.downloadAsync();
    if (!result || cancelledTrackIds.has(track.id)) {
      throw new Error("Download cancelled.");
    }
    if (result.status < 200 || result.status >= 300) {
      throw new Error(`The audio server returned ${result.status}.`);
    }

    const fileInfo = await FileSystem.getInfoAsync(result.uri);
    if (!fileInfo.exists || fileInfo.isDirectory) {
      throw new Error("The downloaded file could not be saved.");
    }
    if (cancelledTrackIds.has(track.id)) {
      throw new Error("Download cancelled.");
    }

    const resolvedTrack = stream.resolvedTrack ?? track;
    const downloadRecord: DownloadedTrack = {
      id: track.id,
      track: {
        ...resolvedTrack,
        id: track.id,
        provider: track.provider,
        fileUrl: result.uri,
        streamUrl: undefined,
        streamHeaders: undefined,
        streamFormat: undefined,
        streamMimeType: undefined,
        streamExpiresAt: undefined,
        quality: stream.quality,
      },
      fileUri: result.uri,
      bytes: fileInfo.size,
      downloadedAt: Date.now(),
      quality: stream.quality,
      format: stream.format,
      mimeType: result.mimeType ?? stream.mimeType,
    };

    useDownloadStore.getState().saveDownload(downloadRecord);
    useDownloadStore.getState().clearTask(track.id);
    return downloadRecord;
  } catch (error) {
    if (destination) {
      await FileSystem.deleteAsync(destination, { idempotent: true }).catch(() => undefined);
    }

    if (!cancelledTrackIds.has(track.id)) {
      const message = error instanceof Error ? error.message : "Could not download this track.";
      useDownloadStore.getState().setTask(track.id, {
        track,
        status: "failed",
        progress: 0,
        bytesWritten: 0,
        error: message,
      });
      logger.error("Failed to download track", track.id, error);
    }
    throw error;
  } finally {
    activeTasks.delete(track.id);
  }
};

const updateQueuePositions = () => {
  const queued = pendingDownloadKeys.flatMap((canonicalKey, index) => {
    const job = queuedJobs.get(canonicalKey);
    return job ? [{ track: job.track, queuePosition: index + 1 }] : [];
  });
  useDownloadStore.getState().setQueuedTasks(queued);
};

const pumpDownloadQueue = () => {
  while (runningDownloadCount < MAX_CONCURRENT_DOWNLOADS && pendingDownloadKeys.length) {
    const canonicalKey = pendingDownloadKeys.shift();
    if (!canonicalKey) {
      break;
    }

    const job = queuedJobs.get(canonicalKey);
    if (!job) {
      continue;
    }

    runningDownloadCount += 1;
    updateQueuePositions();
    void performDownload(job.track)
      .then(job.resolve, job.reject)
      .finally(() => {
        activePromises.delete(canonicalKey);
        queuedJobs.delete(canonicalKey);
        cancelledTrackIds.delete(job.track.id);
        runningDownloadCount = Math.max(runningDownloadCount - 1, 0);
        updateQueuePositions();
        pumpDownloadQueue();
      });
  }
};

const enqueueDownload = (track: Track) => {
  const canonicalKey = buildCanonicalTrackKey(track);
  const existingPromise = activePromises.get(canonicalKey);
  if (existingPromise) {
    return existingPromise;
  }

  let resolveJob!: (download: DownloadedTrack) => void;
  let rejectJob!: (error: unknown) => void;
  const promise = new Promise<DownloadedTrack>((resolve, reject) => {
    resolveJob = resolve;
    rejectJob = reject;
  });

  cancelledTrackIds.delete(track.id);
  activePromises.set(canonicalKey, promise);
  queuedJobs.set(canonicalKey, { track, resolve: resolveJob, reject: rejectJob });
  pendingDownloadKeys.push(canonicalKey);
  updateQueuePositions();
  pumpDownloadQueue();
  return promise;
};

const cancelQueuedDownload = (trackId: string) => {
  const index = pendingDownloadKeys.findIndex((canonicalKey) => queuedJobs.get(canonicalKey)?.track.id === trackId);
  if (index < 0) {
    return false;
  }

  const [canonicalKey] = pendingDownloadKeys.splice(index, 1);
  const job = queuedJobs.get(canonicalKey);
  queuedJobs.delete(canonicalKey);
  activePromises.delete(canonicalKey);
  useDownloadStore.getState().clearTask(trackId);
  updateQueuePositions();
  job?.reject(new Error("Download cancelled."));
  return true;
};

export const downloadService = {
  getNetworkTrack(track: Track) {
    return withoutManagedDownloadFile(track);
  },

  downloadTrack(track: Track) {
    return enqueueDownload(track);
  },

  async downloadTracks(
    tracks: Track[],
    onProgress?: (progress: DownloadBatchProgress) => void,
  ): Promise<DownloadBatchResult> {
    const uniqueTracks = [...new Map(tracks.map((track) => [buildCanonicalTrackKey(track), track])).values()];
    const progress: DownloadBatchProgress = {
      total: uniqueTracks.length,
      completed: 0,
      downloaded: 0,
      skipped: 0,
      failed: 0,
    };
    const failures: DownloadBatchResult["failures"] = [];
    const publishProgress = () => onProgress?.({ ...progress });
    publishProgress();

    await Promise.all(
      uniqueTracks.map(async (track) => {
        const existing = findDownloadForTrack(track, useDownloadStore.getState().downloads);
        if (existing) {
          progress.skipped += 1;
          progress.completed += 1;
          publishProgress();
          return;
        }

        try {
          await downloadService.downloadTrack(track);
          progress.downloaded += 1;
        } catch (error) {
          progress.failed += 1;
          failures.push({ track, error });
        } finally {
          progress.completed += 1;
          publishProgress();
        }
      }),
    );
    return { ...progress, failures };
  },

  async removeDownload(trackId: string) {
    if (cancelQueuedDownload(trackId)) {
      return;
    }

    cancelledTrackIds.add(trackId);
    const activeTask = activeTasks.get(trackId);
    if (activeTask) {
      await activeTask.cancelAsync().catch(() => undefined);
    }

    const store = useDownloadStore.getState();
    const download = store.downloads[trackId];
    if (download) {
      await FileSystem.deleteAsync(download.fileUri, { idempotent: true });
    }
    store.removeDownloadRecord(trackId);
    store.clearTask(trackId);
  },

  async getPlayableTrack(track: Track): Promise<Track | undefined> {
    const download = findDownloadForTrack(track, useDownloadStore.getState().downloads);
    if (!download) {
      return undefined;
    }

    const info = await FileSystem.getInfoAsync(download.fileUri).catch((error) => {
      logger.warn("Could not inspect downloaded track", download.id, error);
      return undefined;
    });
    if (!info) {
      return undefined;
    }
    if (!info.exists || info.isDirectory) {
      useDownloadStore.getState().removeDownloadRecord(download.id);
      return undefined;
    }

    return {
      ...download.track,
      ...track,
      fileUrl: download.fileUri,
      streamUrl: undefined,
      streamHeaders: undefined,
      streamFormat: undefined,
      streamMimeType: undefined,
      streamExpiresAt: undefined,
      quality: download.quality,
    };
  },

  async reconcileDownloads() {
    const downloads = Object.values(useDownloadStore.getState().downloads);
    const results = await Promise.all(
      downloads.map(async (download) => ({
        id: download.id,
        info: await FileSystem.getInfoAsync(download.fileUri).catch((error) => {
          logger.warn("Could not reconcile downloaded track", download.id, error);
          return undefined;
        }),
      })),
    );

    results.forEach(({ id, info }) => {
      if (info && (!info.exists || info.isDirectory)) {
        useDownloadStore.getState().removeDownloadRecord(id);
      }
    });
  },
};

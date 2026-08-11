import TrackPlayer, {
  Event,
  RepeatMode as NativeRepeatMode,
  State,
} from "react-native-track-player";

import { useLibraryStore } from "@/modules/library/libraryStore";
import { downloadService } from "@/modules/downloads/downloadService";
import { usePlayerStore } from "@/modules/player/playerStore";
import { useSleepTimerStore } from "@/modules/player/sleepTimerStore";
import { setupTrackPlayer } from "@/modules/player/trackPlayerSetup";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { logger } from "@/services/logger";
import { getPreferredArtworkUrl } from "@/utils/artwork";
import type { RepeatMode } from "@/types/player";
import type { StreamResult, Track } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

const repeatMap: Record<RepeatMode, NativeRepeatMode> = {
  off: NativeRepeatMode.Off,
  track: NativeRepeatMode.Track,
  // The native queue is filled lazily, so logical queue looping is handled by skipNext.
  queue: NativeRepeatMode.Off,
};

type PlayerListener = { remove: () => void };
type PlayerListenerRuntime = typeof globalThis & {
  __hadooPlayerListeners?: PlayerListener[];
};

const playerListenerRuntime = globalThis as PlayerListenerRuntime;
playerListenerRuntime.__hadooPlayerListeners?.forEach((listener) => listener.remove());
playerListenerRuntime.__hadooPlayerListeners = [];

let listenersAttached = false;
let playbackRequestId = 0;
let isReplacingTrack = false;

const MIN_RESUME_PROGRESS_SECONDS = 15;

const isSameTrack = (left?: Track | null, right?: Track | null) =>
  Boolean(left && right && left.id === right.id && left.provider === right.provider);

type ResolvedPlaybackTrack = {
  originalTrack: Track;
  playableTrack: Track;
  stream: StreamResult;
};

const activeStreamResolutions = new Map<string, Promise<ResolvedPlaybackTrack>>();

const resolveTrackForPlayback = (track: Track): Promise<ResolvedPlaybackTrack> => {
  const audioQuality = useSettingsStore.getState().audioQuality;
  const key = `${track.provider}:${track.id}:${audioQuality}`;
  const existing = activeStreamResolutions.get(key);
  if (existing) {
    return existing;
  }

  const resolution = (async () => {
    const offlineTrack = await downloadService.getPlayableTrack(track);
    const stream: StreamResult = offlineTrack?.fileUrl
      ? {
          url: offlineTrack.fileUrl,
          quality: offlineTrack.quality ?? "high",
          resolvedTrack: offlineTrack,
        }
      : await sourceRegistry.getStreamUrl(
          downloadService.getNetworkTrack(track),
          audioQuality,
        );
    const resolvedTrack = stream.resolvedTrack ?? offlineTrack ?? track;
    const playableTrack: Track = {
      ...resolvedTrack,
      fallbackFromProvider: resolvedTrack.fallbackFromProvider ?? track.provider,
      streamUrl: stream.url,
      streamHeaders: stream.headers,
      streamFormat: stream.format,
      streamMimeType: stream.mimeType,
      streamExpiresAt: stream.expiresAt,
      quality: stream.quality ?? resolvedTrack.quality,
    };

    return { originalTrack: track, playableTrack, stream };
  })();

  activeStreamResolutions.set(key, resolution);
  const clear = () => {
    if (activeStreamResolutions.get(key) === resolution) {
      activeStreamResolutions.delete(key);
    }
  };
  void resolution.then(clear, clear);
  return resolution;
};

const toNativeTrack = ({ playableTrack, stream }: ResolvedPlaybackTrack) => ({
  id: playableTrack.id,
  url: stream.url,
  title: playableTrack.title,
  artist: playableTrack.artist,
  artwork: getPreferredArtworkUrl(playableTrack.artwork, "fullscreen"),
  album: playableTrack.album,
  duration: playableTrack.duration,
  headers: stream.headers,
});

const shouldFireEndOfTrackTimer = (event: {
  index?: number;
  lastIndex?: number;
  lastTrack?: { duration?: number };
  lastPosition: number;
}) => {
  if (event.lastIndex == null || event.lastTrack == null || event.index == null) {
    return false;
  }

  const duration = event.lastTrack.duration ?? 0;
  return duration > 0 && event.lastPosition >= Math.max(duration - 2, 0);
};

export const playerService = {
  syncResumeSession() {
    const { currentTrack, progress, duration } = usePlayerStore.getState();
    if (!currentTrack || progress < MIN_RESUME_PROGRESS_SECONDS) {
      return;
    }

    useLibraryStore.getState().updateResumeSession({
      track: currentTrack,
      position: progress,
      duration: duration || currentTrack.duration || 0,
      updatedAt: Date.now(),
    });
  },

  async setup() {
    await setupTrackPlayer();
    if (!listenersAttached) {
      playerListenerRuntime.__hadooPlayerListeners = [
        TrackPlayer.addEventListener(Event.PlaybackActiveTrackChanged, async (event) => {
          const activeOption = useSleepTimerStore.getState().activeOption;
          if (activeOption === "end_of_track" && shouldFireEndOfTrackTimer(event)) {
            await playerService.stopForSleepTimer();
            return;
          }

          if (!isReplacingTrack) {
            await playerService.syncCurrentTrack();
          }
        }),
        TrackPlayer.addEventListener(Event.PlaybackState, async (event) => {
          usePlayerStore.getState().setPlaying(event.state === State.Playing);
        }),
        TrackPlayer.addEventListener(Event.PlaybackProgressUpdated, async (event) => {
          usePlayerStore.getState().setProgress(event.position, event.duration);
          playerService.syncResumeSession();
          const expiresAt = useSleepTimerStore.getState().expiresAt;
          if (expiresAt != null && Date.now() >= expiresAt) {
            await playerService.stopForSleepTimer();
          }
        }),
      ];
      listenersAttached = true;
    }
    await playerService.syncCurrentTrack();
    await playerService.syncState();
  },

  async playTrack(track: Track, queue?: Track[]) {
    const requestId = ++playbackRequestId;
    const startedAt = Date.now();
    try {
      usePlayerStore.getState().setLoading(true, "Loading track…");
      await this.setup();
      const requestedQueue = queue?.length ? queue : [track];
      const nextQueue = requestedQueue.some((item) => isSameTrack(item, track))
        ? requestedQueue
        : [track, ...requestedQueue];
      const selected = await resolveTrackForPlayback(track);
      logger.info("Player: selected stream resolved in", Date.now() - startedAt, "ms");

      if (requestId !== playbackRequestId) {
        return;
      }

      const logicalQueue = nextQueue.map((item) =>
        isSameTrack(item, track) ? selected.playableTrack : item,
      );

      logger.info("Player: resolved selected track", selected.playableTrack.id, "logical queue", logicalQueue.length);
      logger.info("Player: handing resolved stream to native player", {
        mimeType: selected.stream.mimeType,
        format: selected.stream.format,
        quality: selected.stream.quality,
      });

      isReplacingTrack = true;
      usePlayerStore.getState().setQueue(logicalQueue);
      logger.info("Player: reset start");
      await TrackPlayer.reset();
      logger.info("Player: reset success");
      logger.info("Player: add selected track", selected.playableTrack.id);
      await TrackPlayer.add(toNativeTrack(selected));
      logger.info("Player: add success");
      logger.info("Player: play start");
      await TrackPlayer.play();
      logger.info("Player: play called after", Date.now() - startedAt, "ms");

      usePlayerStore.getState().setCurrentTrack(selected.playableTrack);
      usePlayerStore.getState().setPlaying(true);
      usePlayerStore.getState().setProgress(0, track.duration ?? 0);
      usePlayerStore.getState().setError(undefined);
      useLibraryStore.getState().addRecent(track);
      useLibraryStore.getState().updateResumeSession({
        track: selected.playableTrack,
        position: 0,
        duration: track.duration ?? 0,
        updatedAt: Date.now(),
      });
      isReplacingTrack = false;
    } catch (error) {
      logger.error("Failed to play track", error);
      const message =
        track.provider === "youtube_music_experimental" || track.provider === "youtube_experimental"
          ? "YouTube resolved a stream, but playback handoff failed."
          : "Could not play this track.";
      usePlayerStore.getState().setError(message);
      throw new StreamResolveError(message);
    } finally {
      if (requestId === playbackRequestId) {
        isReplacingTrack = false;
        usePlayerStore.getState().setLoading(false);
      }
    }
  },

  async resumeStoredTrack(track: Track, position: number) {
    await this.playTrack(track, [track]);
    if (position > 0) {
      await this.seek(position);
    }
  },

  async pause() {
    await TrackPlayer.pause();
    usePlayerStore.getState().setPlaying(false);
    this.syncResumeSession();
  },

  async stopForSleepTimer() {
    await TrackPlayer.pause();
    usePlayerStore.getState().setPlaying(false);
    useSleepTimerStore.getState().clearTimer();
  },

  async dismissMiniPlayer() {
    this.syncResumeSession();
    await TrackPlayer.reset();
    usePlayerStore.getState().reset();
    useSleepTimerStore.getState().clearTimer();
  },

  async resume() {
    await TrackPlayer.play();
    usePlayerStore.getState().setPlaying(true);
  },

  async togglePlayback() {
    const playbackState = await TrackPlayer.getPlaybackState();
    const isActivelyPlaying =
      playbackState.state === State.Playing ||
      playbackState.state === State.Buffering ||
      playbackState.state === State.Loading;

    if (isActivelyPlaying) {
      await this.pause();
      return;
    }

    await this.resume();
  },

  async skipNext() {
    const snapshot = usePlayerStore.getState();
    const currentIndex = snapshot.queue.findIndex((item) => isSameTrack(item, snapshot.currentTrack));
    const nextIndex =
      currentIndex >= 0 && currentIndex < snapshot.queue.length - 1
        ? currentIndex + 1
        : snapshot.repeatMode === "queue" && snapshot.queue.length > 1
          ? 0
          : -1;
    const nextTrack = nextIndex >= 0 ? snapshot.queue[nextIndex] : undefined;
    if (!nextTrack) {
      return;
    }

    const [activeIndex, nativeQueue] = await Promise.all([
      TrackPlayer.getActiveTrackIndex(),
      TrackPlayer.getQueue(),
    ]);
    const nativeNext = activeIndex == null ? undefined : nativeQueue[activeIndex + 1];
    if (String(nativeNext?.id ?? "") === nextTrack.id) {
      await TrackPlayer.skipToNext();
      await this.syncCurrentTrack();
      return;
    }

    await this.playTrack(nextTrack, snapshot.queue);
  },

  async skipPrevious() {
    const progress = await TrackPlayer.getProgress();
    if (progress.position > 3) {
      await this.seek(0);
      return;
    }

    const snapshot = usePlayerStore.getState();
    const currentIndex = snapshot.queue.findIndex((item) => isSameTrack(item, snapshot.currentTrack));
    const previousTrack = currentIndex > 0 ? snapshot.queue[currentIndex - 1] : undefined;
    if (!previousTrack) {
      await this.seek(0);
      return;
    }

    const [activeIndex, nativeQueue] = await Promise.all([
      TrackPlayer.getActiveTrackIndex(),
      TrackPlayer.getQueue(),
    ]);
    const nativePrevious = activeIndex == null ? undefined : nativeQueue[activeIndex - 1];
    if (String(nativePrevious?.id ?? "") === previousTrack.id) {
      await TrackPlayer.skipToPrevious();
      await this.syncCurrentTrack();
      return;
    }

    await this.playTrack(previousTrack, snapshot.queue);
  },

  async seek(position: number) {
    await TrackPlayer.seekTo(position);
    const duration = usePlayerStore.getState().duration;
    usePlayerStore.getState().setProgress(position, duration);
    this.syncResumeSession();
  },

  async toggleRepeat() {
    const current = usePlayerStore.getState().repeatMode;
    const next: RepeatMode = current === "off" ? "queue" : current === "queue" ? "track" : "off";
    await TrackPlayer.setRepeatMode(repeatMap[next]);
    usePlayerStore.getState().setRepeatMode(next);
  },

  toggleShuffle() {
    const current = usePlayerStore.getState().shuffle;
    usePlayerStore.getState().setShuffle(!current);
  },

  async syncState() {
    const [state, progress] = await Promise.all([
      TrackPlayer.getPlaybackState(),
      TrackPlayer.getProgress(),
    ]);
    usePlayerStore.getState().setPlaying(state.state === State.Playing);
    usePlayerStore.getState().setProgress(progress.position, progress.duration);
  },

  async syncCurrentTrack() {
    const activeTrack = await TrackPlayer.getActiveTrack();
    if (!activeTrack) {
      usePlayerStore.getState().setCurrentTrack(null);
      usePlayerStore.getState().setProgress(0, 0);
      return;
    }

    const queue = usePlayerStore.getState().queue;
    const activeTrackId = String(activeTrack.id ?? "");
    const currentTrack = queue.find((item) => item.id === activeTrackId) ?? null;
    usePlayerStore.getState().setCurrentTrack(currentTrack);
    if (currentTrack) {
      useLibraryStore.getState().addRecent(currentTrack);
      playerService.syncResumeSession();
    }
  },
};

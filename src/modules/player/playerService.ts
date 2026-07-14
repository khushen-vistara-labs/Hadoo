import TrackPlayer, {
  Event,
  RepeatMode as NativeRepeatMode,
  State,
} from "react-native-track-player";

import { useLibraryStore } from "@/modules/library/libraryStore";
import { usePlayerStore } from "@/modules/player/playerStore";
import { useSleepTimerStore } from "@/modules/player/sleepTimerStore";
import { setupTrackPlayer } from "@/modules/player/trackPlayerSetup";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { logger } from "@/services/logger";
import { getPreferredArtworkUrl } from "@/utils/artwork";
import type { RepeatMode } from "@/types/player";
import type { Track } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

const repeatMap: Record<RepeatMode, NativeRepeatMode> = {
  off: NativeRepeatMode.Off,
  track: NativeRepeatMode.Track,
  queue: NativeRepeatMode.Queue,
};

let listenersAttached = false;

const MIN_RESUME_PROGRESS_SECONDS = 15;

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
      TrackPlayer.addEventListener(Event.PlaybackActiveTrackChanged, async (event) => {
        const activeOption = useSleepTimerStore.getState().activeOption;
        if (activeOption === "end_of_track" && shouldFireEndOfTrackTimer(event)) {
          await playerService.stopForSleepTimer();
          return;
        }

        await playerService.syncCurrentTrack();
      });
      TrackPlayer.addEventListener(Event.PlaybackState, async (event) => {
        usePlayerStore.getState().setPlaying(event.state === State.Playing);
      });
      TrackPlayer.addEventListener(Event.PlaybackProgressUpdated, async (event) => {
        usePlayerStore.getState().setProgress(event.position, event.duration);
        playerService.syncResumeSession();
        const expiresAt = useSleepTimerStore.getState().expiresAt;
        if (expiresAt != null && Date.now() >= expiresAt) {
          await playerService.stopForSleepTimer();
        }
      });
      listenersAttached = true;
    }
    await playerService.syncCurrentTrack();
    await playerService.syncState();
  },

  async playTrack(track: Track, queue?: Track[]) {
    try {
      await this.setup();
      const nextQueue = queue ?? [track];
      const audioQuality = useSettingsStore.getState().audioQuality;
      const resolvedQueue = await Promise.all(
        nextQueue.map(async (item) => ({
          track: item,
          stream: await sourceRegistry.getStreamUrl(item, audioQuality),
        })),
      );
      const selected = resolvedQueue.find((item) => item.track.id === track.id);

      logger.info("Player: resolved queue", resolvedQueue.length);
      logger.info("Player: final resolved stream url", selected?.stream.url ?? "missing");
      logger.info("Player: stream request headers", selected?.stream.headers ?? {});
      logger.info("Player: handing stream to player", {
        url: selected?.stream.url,
        mimeType: selected?.stream.mimeType,
        format: selected?.stream.format,
        quality: selected?.stream.quality,
        headers: selected?.stream.headers,
      });

      logger.info("Player: reset start");
      await TrackPlayer.reset();
      logger.info("Player: reset success");
      logger.info(
        "Player: add start",
        resolvedQueue.map(({ track: queueTrack, stream }) => ({
          id: queueTrack.id,
          url: stream.url,
          title: queueTrack.title,
          headers: stream.headers,
        })),
      );
      await TrackPlayer.add(
        resolvedQueue.map(({ track: queueTrack, stream }) => ({
          id: queueTrack.id,
          url: stream.url,
          title: queueTrack.title,
          artist: queueTrack.artist,
          artwork: getPreferredArtworkUrl(queueTrack.artwork, "fullscreen"),
          album: queueTrack.album,
          duration: queueTrack.duration,
          headers: stream.headers,
        })),
      );
      logger.info("Player: add success");
      const index = nextQueue.findIndex((item) => item.id === track.id);
      if (index > 0) {
        logger.info("Player: skip start", index);
        await TrackPlayer.skip(index);
        logger.info("Player: skip success", index);
      }
      logger.info("Player: play start");
      await TrackPlayer.play();
      logger.info("Player: play called");

      usePlayerStore.getState().setQueue(
        resolvedQueue.map(({ track: queueTrack, stream }) => ({
          ...queueTrack,
          streamUrl: stream.url,
          quality: stream.quality ?? queueTrack.quality,
        })),
      );
      usePlayerStore.getState().setCurrentTrack(
        resolvedQueue.find((item) => item.track.id === track.id)?.track ?? track,
      );
      usePlayerStore.getState().setPlaying(true);
      usePlayerStore.getState().setProgress(0, track.duration ?? 0);
      usePlayerStore.getState().setError(undefined);
      useLibraryStore.getState().addRecent(track);
      useLibraryStore.getState().updateResumeSession({
        track,
        position: 0,
        duration: track.duration ?? 0,
        updatedAt: Date.now(),
      });
    } catch (error) {
      logger.error("Failed to play track", error);
      const message =
        track.provider === "youtube_music_experimental"
          ? "YouTube resolved a stream, but playback handoff failed."
          : "Could not play this track.";
      usePlayerStore.getState().setError(message);
      throw new StreamResolveError(message);
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

  async skipNext() {
    await TrackPlayer.skipToNext();
    await this.syncCurrentTrack();
  },

  async skipPrevious() {
    await TrackPlayer.skipToPrevious();
    await this.syncCurrentTrack();
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
    const activeIndex = await TrackPlayer.getActiveTrackIndex();
    if (activeIndex == null) {
      usePlayerStore.getState().setCurrentTrack(null);
      usePlayerStore.getState().setProgress(0, 0);
      return;
    }

    const queue = usePlayerStore.getState().queue;
    const currentTrack = queue[activeIndex] ?? null;
    usePlayerStore.getState().setCurrentTrack(currentTrack);
    if (currentTrack) {
      useLibraryStore.getState().addRecent(currentTrack);
      playerService.syncResumeSession();
    }
  },
};

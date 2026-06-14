import TrackPlayer, { RepeatMode as NativeRepeatMode, State } from "react-native-track-player";

import { useLibraryStore } from "@/modules/library/libraryStore";
import { usePlayerStore } from "@/modules/player/playerStore";
import { setupTrackPlayer } from "@/modules/player/trackPlayerSetup";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { logger } from "@/services/logger";
import type { RepeatMode } from "@/types/player";
import type { Track } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

const repeatMap: Record<RepeatMode, NativeRepeatMode> = {
  off: NativeRepeatMode.Off,
  track: NativeRepeatMode.Track,
  queue: NativeRepeatMode.Queue,
};

export const playerService = {
  async setup() {
    await setupTrackPlayer();
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
          artwork: queueTrack.artwork,
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
      usePlayerStore.getState().setError(undefined);
      useLibraryStore.getState().addRecent(track);
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

  async pause() {
    await TrackPlayer.pause();
    usePlayerStore.getState().setPlaying(false);
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
    const state = await TrackPlayer.getPlaybackState();
    usePlayerStore.getState().setPlaying(state.state === State.Playing);
  },

  async syncCurrentTrack() {
    const activeIndex = await TrackPlayer.getActiveTrackIndex();
    if (activeIndex == null) {
      usePlayerStore.getState().setCurrentTrack(null);
      return;
    }

    const queue = usePlayerStore.getState().queue;
    usePlayerStore.getState().setCurrentTrack(queue[activeIndex] ?? null);
  },
};

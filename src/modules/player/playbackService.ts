import TrackPlayer, { Event, State } from "react-native-track-player";

import { usePlayerStore } from "@/modules/player/playerStore";
import { logger } from "@/services/logger";

export const playbackService = async () => {
  TrackPlayer.addEventListener(Event.PlaybackActiveTrackChanged, async (event) => {
    logger.info("Player event: active track changed", event.index, event.lastIndex);
    const queue = usePlayerStore.getState().queue;
    const nextTrack = event.index != null ? queue[event.index] ?? null : null;
    usePlayerStore.getState().setCurrentTrack(nextTrack);
  });

  TrackPlayer.addEventListener(Event.PlaybackState, async (event) => {
    logger.info("Player event: playback state", event.state);
    usePlayerStore.getState().setPlaying(event.state === State.Playing);
  });

  TrackPlayer.addEventListener(Event.PlaybackError, async (event) => {
    logger.error("Player event: playback error", event.code, event.message);
  });
};

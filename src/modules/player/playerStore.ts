import { create } from "zustand";

import type { PlaybackSnapshot, RepeatMode } from "@/types/player";
import type { Track } from "@/types/track";

type PlayerStore = PlaybackSnapshot & {
  setCurrentTrack: (track: Track | null) => void;
  setQueue: (queue: Track[]) => void;
  setPlaying: (isPlaying: boolean) => void;
  setLoading: (isLoading: boolean, loadingLabel?: string) => void;
  setProgress: (progress: number, duration: number) => void;
  setShuffle: (shuffle: boolean) => void;
  setRepeatMode: (repeatMode: RepeatMode) => void;
  setError: (error?: string) => void;
  reset: () => void;
};

export const usePlayerStore = create<PlayerStore>((set) => ({
  currentTrack: null,
  queue: [],
  isPlaying: false,
  isLoading: false,
  loadingLabel: undefined,
  progress: 0,
  duration: 0,
  shuffle: false,
  repeatMode: "off",
  error: undefined,
  setCurrentTrack: (currentTrack) => set({ currentTrack }),
  setQueue: (queue) => set({ queue }),
  setPlaying: (isPlaying) => set({ isPlaying }),
  setLoading: (isLoading, loadingLabel) => set({ isLoading, loadingLabel }),
  setProgress: (progress, duration) => set({ progress, duration }),
  setShuffle: (shuffle) => set({ shuffle }),
  setRepeatMode: (repeatMode) => set({ repeatMode }),
  setError: (error) => set({ error }),
  reset: () =>
    set({
      currentTrack: null,
      queue: [],
      isPlaying: false,
      isLoading: false,
      loadingLabel: undefined,
      progress: 0,
      duration: 0,
      error: undefined,
    }),
}));

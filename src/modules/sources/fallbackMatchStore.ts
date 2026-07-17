import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import type { PlaybackMatchKind, Track } from "@/types/track";
import type { MusicProvider } from "@/types/source";
import { appStorage } from "@/store/persistence";

type FallbackMatchRecord = {
  targetProvider: MusicProvider;
  localId: string;
  sourceUrl?: string;
  title: string;
  artist: string;
  artwork?: Track["artwork"];
  duration?: number;
  matchedAt: number;
  matchKind: PlaybackMatchKind;
};

type FallbackMatchStore = {
  matches: Record<string, FallbackMatchRecord>;
  getMatch: (key: string) => FallbackMatchRecord | undefined;
  saveMatch: (key: string, value: FallbackMatchRecord) => void;
};

export const useFallbackMatchStore = create<FallbackMatchStore>()(
  persist(
    (set, get) => ({
      matches: {},
      getMatch: (key) => get().matches[key],
      saveMatch: (key, value) =>
        set((state) => ({
          matches: {
            ...state.matches,
            [key]: value,
          },
        })),
    }),
    {
      name: "fallback-match-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);

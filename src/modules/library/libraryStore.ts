import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { mockTracks } from "@/data/mockTracks";
import { appStorage } from "@/store/persistence";
import type { Track } from "@/types/track";

type LibraryStore = {
  likedSongs: Track[];
  recentlyPlayed: Track[];
  toggleLike: (track: Track) => void;
  addRecent: (track: Track) => void;
  clearRecentlyPlayed: () => void;
};

export const useLibraryStore = create<LibraryStore>()(
  persist(
    (set, get) => ({
      likedSongs: [mockTracks[0]],
      recentlyPlayed: mockTracks.slice(0, 3),
      toggleLike: (track) => {
        const exists = get().likedSongs.some((item) => item.id === track.id);
        set({
          likedSongs: exists
            ? get().likedSongs.filter((item) => item.id !== track.id)
            : [track, ...get().likedSongs],
        });
      },
      addRecent: (track) => {
        const next = [track, ...get().recentlyPlayed.filter((item) => item.id !== track.id)].slice(0, 12);
        set({ recentlyPlayed: next });
      },
      clearRecentlyPlayed: () => set({ recentlyPlayed: [] }),
    }),
    {
      name: "library-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);

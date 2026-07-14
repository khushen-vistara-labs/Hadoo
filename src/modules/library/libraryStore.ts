import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import type { Track } from "@/types/track";

type ResumeSession = {
  track: Track;
  position: number;
  duration: number;
  updatedAt: number;
};

type LibraryStore = {
  likedSongs: Track[];
  recentlyPlayed: Track[];
  resumeSession?: ResumeSession;
  toggleLike: (track: Track) => void;
  addRecent: (track: Track) => void;
  updateResumeSession: (session?: ResumeSession) => void;
  clearRecentlyPlayed: () => void;
};

export const useLibraryStore = create<LibraryStore>()(
  persist(
    (set, get) => ({
      likedSongs: [],
      recentlyPlayed: [],
      resumeSession: undefined,
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
      updateResumeSession: (resumeSession) => set({ resumeSession }),
      clearRecentlyPlayed: () => set({ recentlyPlayed: [] }),
    }),
    {
      name: "library-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);

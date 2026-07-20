import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import { buildCanonicalTrackKey } from "@/modules/sources/sourceUtils";
import type { Track, TrackQuality } from "@/types/track";

export type DownloadedTrack = {
  id: string;
  track: Track;
  fileUri: string;
  bytes: number;
  downloadedAt: number;
  quality: TrackQuality;
  format?: string;
  mimeType?: string;
};

export type DownloadTaskStatus = "queued" | "resolving" | "downloading" | "failed";

export type DownloadTask = {
  track: Track;
  status: DownloadTaskStatus;
  progress: number;
  bytesWritten: number;
  totalBytes?: number;
  queuePosition?: number;
  error?: string;
};

export const findDownloadForTrack = (
  track: Track,
  downloads: Record<string, DownloadedTrack>,
) =>
  downloads[track.id] ??
  Object.values(downloads).find(
    (download) => buildCanonicalTrackKey(download.track) === buildCanonicalTrackKey(track),
  );

type DownloadStore = {
  downloads: Record<string, DownloadedTrack>;
  tasks: Record<string, DownloadTask>;
  hasHydrated: boolean;
  saveDownload: (download: DownloadedTrack) => void;
  removeDownloadRecord: (trackId: string) => void;
  setTask: (trackId: string, task: DownloadTask) => void;
  setQueuedTasks: (items: { track: Track; queuePosition: number }[]) => void;
  clearTask: (trackId: string) => void;
  setHasHydrated: (hasHydrated: boolean) => void;
};

export const useDownloadStore = create<DownloadStore>()(
  persist(
    (set) => ({
      downloads: {},
      tasks: {},
      hasHydrated: false,
      saveDownload: (download) =>
        set((state) => ({
          downloads: {
            ...state.downloads,
            [download.id]: download,
          },
        })),
      removeDownloadRecord: (trackId) =>
        set((state) => {
          const downloads = { ...state.downloads };
          delete downloads[trackId];
          return { downloads };
        }),
      setTask: (trackId, task) =>
        set((state) => ({
          tasks: {
            ...state.tasks,
            [trackId]: task,
          },
        })),
      setQueuedTasks: (items) =>
        set((state) => {
          const tasks = { ...state.tasks };
          items.forEach(({ queuePosition, track }) => {
            tasks[track.id] = {
              track,
              status: "queued",
              progress: 0,
              bytesWritten: 0,
              queuePosition,
            };
          });
          return { tasks };
        }),
      clearTask: (trackId) =>
        set((state) => {
          const tasks = { ...state.tasks };
          delete tasks[trackId];
          return { tasks };
        }),
      setHasHydrated: (hasHydrated) => set({ hasHydrated }),
    }),
    {
      name: "download-store",
      storage: createJSONStorage(() => appStorage),
      partialize: (state) => ({ downloads: state.downloads }),
      onRehydrateStorage: () => (state) => {
        state?.setHasHydrated(true);
      },
    },
  ),
);

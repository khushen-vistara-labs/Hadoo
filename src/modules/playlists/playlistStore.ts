import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import type { Playlist } from "@/types/playlist";
import type { Track } from "@/types/track";

const createPlaylistId = () => `playlist-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;

const normalizePlaylist = (playlist: Playlist & { trackIds?: string[]; tracks?: Track[] }): Playlist => ({
  id: playlist.id,
  title: playlist.title,
  description: playlist.description,
  artwork: playlist.artwork ?? playlist.tracks?.[0]?.artwork,
  tracks: playlist.tracks ?? [],
  updatedAt: playlist.updatedAt ?? Date.now(),
});

type PlaylistStore = {
  playlists: Playlist[];
  createPlaylist: (input: { title: string; description?: string; initialTrack?: Track }) => Playlist | undefined;
  deletePlaylist: (playlistId: string) => void;
  addTrackToPlaylist: (playlistId: string, track: Track) => void;
  removeTrackFromPlaylist: (playlistId: string, trackId: string) => void;
};

export const usePlaylistStore = create<PlaylistStore>()(
  persist(
    (set, get) => ({
      playlists: [],
      createPlaylist: ({ title, description, initialTrack }) => {
        const normalizedTitle = title.trim();
        if (!normalizedTitle) {
          return undefined;
        }

        const playlist: Playlist = {
          id: createPlaylistId(),
          title: normalizedTitle,
          description: description?.trim() || undefined,
          artwork: initialTrack?.artwork,
          tracks: initialTrack ? [initialTrack] : [],
          updatedAt: Date.now(),
        };

        set({ playlists: [playlist, ...get().playlists] });
        return playlist;
      },
      deletePlaylist: (playlistId) => {
        set({
          playlists: get().playlists.filter((playlist) => playlist.id !== playlistId),
        });
      },
      addTrackToPlaylist: (playlistId, track) => {
        set({
          playlists: get().playlists.map((playlist) =>
            playlist.id === playlistId && !playlist.tracks.some((item) => item.id === track.id)
              ? {
                  ...playlist,
                  artwork: playlist.artwork ?? track.artwork,
                  tracks: [...playlist.tracks, track],
                  updatedAt: Date.now(),
                }
              : playlist,
          ),
        });
      },
      removeTrackFromPlaylist: (playlistId, trackId) => {
        set({
          playlists: get().playlists.map((playlist) =>
            playlist.id === playlistId
              ? {
                  ...playlist,
                  tracks: playlist.tracks.filter((track) => track.id !== trackId),
                  artwork:
                    playlist.artwork && playlist.tracks[0]?.id !== trackId
                      ? playlist.artwork
                      : playlist.tracks.find((track) => track.id !== trackId)?.artwork,
                  updatedAt: Date.now(),
                }
              : playlist,
          ),
        });
      },
    }),
    {
      name: "playlist-store",
      storage: createJSONStorage(() => appStorage),
      version: 2,
      migrate: (persistedState) => {
        const state = persistedState as { playlists?: (Playlist & { trackIds?: string[]; tracks?: Track[] })[] } | undefined;
        return {
          playlists: (state?.playlists ?? []).map(normalizePlaylist),
        };
      },
    },
  ),
);

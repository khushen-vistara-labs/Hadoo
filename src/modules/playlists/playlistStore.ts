import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { appStorage } from "@/store/persistence";
import type { Playlist } from "@/types/playlist";
import type { Track } from "@/types/track";

type PlaylistStore = {
  playlists: Playlist[];
  addTrackToPlaylist: (playlistId: string, track: Track) => void;
  removeTrackFromPlaylist: (playlistId: string, trackId: string) => void;
};

export const usePlaylistStore = create<PlaylistStore>()(
  persist(
    (set, get) => ({
      playlists: [],
      addTrackToPlaylist: (playlistId, track) => {
        set({
          playlists: get().playlists.map((playlist) =>
            playlist.id === playlistId && !playlist.trackIds.includes(track.id)
              ? { ...playlist, trackIds: [...playlist.trackIds, track.id] }
              : playlist,
          ),
        });
      },
      removeTrackFromPlaylist: (playlistId, trackId) => {
        set({
          playlists: get().playlists.map((playlist) =>
            playlist.id === playlistId
              ? { ...playlist, trackIds: playlist.trackIds.filter((id) => id !== trackId) }
              : playlist,
          ),
        });
      },
    }),
    {
      name: "playlist-store",
      storage: createJSONStorage(() => appStorage),
    },
  ),
);

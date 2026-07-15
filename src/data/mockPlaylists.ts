import { mockTracks } from "@/data/mockTracks";
import type { Playlist } from "@/types/playlist";

export const mockPlaylists: Playlist[] = [
  {
    id: "playlist-night-drive",
    title: "Night Drive",
    description: "Clean synths, soft bass, and late city motion.",
    tracks: mockTracks.filter((track) => ["mock-1", "mock-2", "mock-3"].includes(track.id)),
    updatedAt: 1,
  },
  {
    id: "playlist-focus",
    title: "Focus Tunnels",
    description: "Steady tempo for calm working hours.",
    tracks: mockTracks.filter((track) => ["mock-2", "mock-4"].includes(track.id)),
    updatedAt: 2,
  },
];

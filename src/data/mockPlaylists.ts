import type { Playlist } from "@/types/playlist";

export const mockPlaylists: Playlist[] = [
  {
    id: "playlist-night-drive",
    title: "Night Drive",
    description: "Clean synths, soft bass, and late city motion.",
    trackIds: ["mock-1", "mock-2", "mock-3"],
  },
  {
    id: "playlist-focus",
    title: "Focus Tunnels",
    description: "Steady tempo for calm working hours.",
    trackIds: ["mock-2", "mock-4"],
  },
];

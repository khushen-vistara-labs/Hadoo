import type { LyricLine, Track } from "@/types/track";

export const mockTracks: Track[] = [
  {
    id: "mock-1",
    provider: "mock",
    title: "Solar Drift",
    artist: "Neon Valleys",
    album: "Afterlight",
    artwork: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?auto=format&fit=crop&w=800&q=80",
    duration: 214,
    streamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    quality: "high",
  },
  {
    id: "mock-2",
    provider: "mock",
    title: "Velvet Current",
    artist: "Mira Harbor",
    album: "Blue Rooms",
    artwork: "https://images.unsplash.com/photo-1501612780327-45045538702b?auto=format&fit=crop&w=800&q=80",
    duration: 188,
    streamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    quality: "high",
  },
  {
    id: "mock-3",
    provider: "mock",
    title: "Glass Signals",
    artist: "Static Bloom",
    album: "Night Routes",
    artwork: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80",
    duration: 242,
    streamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    quality: "high",
  },
  {
    id: "mock-4",
    provider: "mock",
    title: "After Dawn",
    artist: "Juniper Echo",
    album: "Low Tide",
    artwork: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=800&q=80",
    duration: 201,
    streamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    quality: "medium",
  },
];

export const mockLyrics: Record<string, LyricLine[]> = {
  "mock-1": [
    { time: 0, text: "Streetlights bloom in ultraviolet haze" },
    { time: 18, text: "We ride the skyline through electric rain" },
    { time: 36, text: "Every signal bends into your name" },
  ],
  "mock-2": [
    { time: 0, text: "Blue reflections on the window frame" },
    { time: 16, text: "A slow pulse hums beneath the floor" },
    { time: 33, text: "We keep the quiet beating more" },
  ],
};

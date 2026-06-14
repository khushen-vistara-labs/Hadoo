import type { Track } from "@/types/track";

export type RepeatMode = "off" | "track" | "queue";

export type PlaybackSnapshot = {
  currentTrack: Track | null;
  queue: Track[];
  isPlaying: boolean;
  progress: number;
  duration: number;
  shuffle: boolean;
  repeatMode: RepeatMode;
  error?: string;
};

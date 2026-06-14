import type { Track } from "@/types/track";

export type Playlist = {
  id: string;
  title: string;
  description?: string;
  artwork?: string;
  trackIds: string[];
  tracks?: Track[];
};

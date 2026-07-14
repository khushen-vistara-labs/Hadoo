import type { ArtworkLike } from "@/types/artwork";
import type { Track } from "@/types/track";

export type Playlist = {
  id: string;
  title: string;
  description?: string;
  artwork?: ArtworkLike;
  trackIds: string[];
  tracks?: Track[];
};

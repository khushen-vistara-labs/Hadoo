import type { MusicProvider } from "@/types/source";
import type { Artwork } from "@/types/artwork";
import type { Track } from "@/types/track";

export type MediaItemKind = "track" | "album" | "artist" | "playlist";
export type HomeSectionCardType = "track_list" | "media_grid";

export type MediaItem = {
  id: string;
  provider: MusicProvider;
  kind: MediaItemKind;
  title: string;
  subtitle?: string;
  artwork?: Artwork;
  track?: Track;
  browseId?: string;
  playlistId?: string;
  artistId?: string;
  albumId?: string;
  sourceUrl?: string;
  isPlayable: boolean;
};

export type HomeSection = {
  id: string;
  provider: MusicProvider;
  title: string;
  subtitle?: string;
  cardType: HomeSectionCardType;
  items: MediaItem[];
  continuationToken?: string;
};

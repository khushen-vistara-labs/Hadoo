import type { MusicProvider } from "@/types/source";
import type { ArtworkLike } from "@/types/artwork";

export type TrackQuality = "low" | "medium" | "high" | "lossless" | "unknown";

export type StreamSource = {
  url: string;
  quality: TrackQuality;
  format?: string;
  headers?: Record<string, string>;
  expiresAt?: number;
  mimeType?: string;
};

export type PlaybackMatchKind = "cached_fallback" | "isrc" | "metadata_search";

export type Track = {
  id: string;
  provider: MusicProvider;
  localId?: string;
  title: string;
  artist: string;
  artists?: string[];
  album?: string;
  genres?: string[];
  isrc?: string;
  upc?: string;
  artwork?: ArtworkLike;
  duration?: number;
  streamUrl?: string;
  streamHeaders?: Record<string, string>;
  streamFormat?: string;
  streamMimeType?: string;
  streamExpiresAt?: number;
  sourceUrl?: string;
  fileUrl?: string;
  providerTrackId?: string;
  providerAlbumId?: string;
  providerArtistId?: string;
  playbackProvider?: MusicProvider;
  fallbackFromProvider?: MusicProvider;
  playbackMatchKind?: PlaybackMatchKind;
  isExplicit?: boolean;
  quality?: TrackQuality;
};

export type StreamResult = StreamSource & {
  resolvedTrack?: Track;
};

export type LyricLine = {
  time?: number;
  text: string;
};

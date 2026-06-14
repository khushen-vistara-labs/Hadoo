import type { MusicProvider } from "@/types/source";

export type TrackQuality = "low" | "medium" | "high" | "lossless" | "unknown";

export type StreamSource = {
  url: string;
  quality: TrackQuality;
  format?: string;
  headers?: Record<string, string>;
  expiresAt?: number;
  mimeType?: string;
};

export type Track = {
  id: string;
  provider: MusicProvider;
  localId?: string;
  title: string;
  artist: string;
  artists?: string[];
  album?: string;
  artwork?: string;
  duration?: number;
  streamUrl?: string;
  sourceUrl?: string;
  fileUrl?: string;
  providerTrackId?: string;
  providerAlbumId?: string;
  providerArtistId?: string;
  isExplicit?: boolean;
  quality?: TrackQuality;
};

export type StreamResult = StreamSource;

export type LyricLine = {
  time?: number;
  text: string;
};

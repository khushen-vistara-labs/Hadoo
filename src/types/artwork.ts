import type { ImageSourcePropType, ImageURISource } from "react-native";

export type ArtworkLayout = "square" | "portrait" | "landscape" | "circle";
export type ArtworkVariant = "thumbnail" | "card" | "hero" | "fullscreen";
export type ArtworkCategory = "track" | "album" | "artist" | "playlist" | "hero";

export type Artwork = {
  url: string;
  urlLow?: string;
  urlHigh?: string;
  layout: ArtworkLayout;
  dominantColor?: string;
};

export type ArtworkLike = Artwork | string | undefined;

export type ResolvedArtworkCandidate = {
  uri: string;
  isLocal: boolean;
};

export type ResolvedImageSource = ImageURISource | ImageSourcePropType;

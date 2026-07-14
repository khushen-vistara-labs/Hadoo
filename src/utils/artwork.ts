import { PixelRatio } from "react-native";

import type {
  Artwork,
  ArtworkCategory,
  ArtworkLike,
  ArtworkVariant,
  ResolvedArtworkCandidate,
  ResolvedImageSource,
} from "@/types/artwork";

const failedUrls = new Set<string>();

const isRemoteUrl = (value: string) => /^https?:\/\//i.test(value);
const isFileUri = (value: string) => /^file:\/\//i.test(value);
const isAbsolutePath = (value: string) => value.startsWith("/");

export const isLocalArtworkPath = (value: string) => isFileUri(value) || isAbsolutePath(value);

export const normalizeArtworkInput = (artwork?: ArtworkLike): Artwork | undefined => {
  if (!artwork) {
    return undefined;
  }

  if (typeof artwork === "string") {
    return {
      url: artwork,
      layout: "square",
    };
  }

  return artwork;
};

const normalizeUri = (value: string) => {
  if (isAbsolutePath(value)) {
    return `file://${value}`;
  }

  return value;
};

export const markArtworkUrlFailed = (uri?: string) => {
  if (uri) {
    failedUrls.add(uri);
  }
};

export const isArtworkUrlKnownBroken = (uri?: string) => (uri ? failedUrls.has(uri) : false);

export const getPreferredArtworkUrl = (artwork?: ArtworkLike, variant: ArtworkVariant = "card") => {
  const normalized = normalizeArtworkInput(artwork);
  if (!normalized) {
    return undefined;
  }

  switch (variant) {
    case "thumbnail":
      return normalized.urlLow ?? normalized.url;
    case "hero":
    case "fullscreen":
      return normalized.urlHigh ?? normalized.url ?? normalized.urlLow;
    case "card":
    default:
      return normalized.url ?? normalized.urlLow;
  }
};

export const getArtworkCandidates = (
  artwork?: ArtworkLike,
  fallback?: ArtworkLike,
  variant: ArtworkVariant = "card",
): ResolvedArtworkCandidate[] => {
  const candidates = [getPreferredArtworkUrl(artwork, variant), getPreferredArtworkUrl(fallback, variant)]
    .filter(Boolean)
    .map((uri) => normalizeUri(uri as string))
    .filter((uri, index, list) => list.indexOf(uri) === index)
    .filter((uri) => !isArtworkUrlKnownBroken(uri))
    .filter((uri) => isRemoteUrl(uri) || isLocalArtworkPath(uri))
    .map((uri) => ({
      uri,
      isLocal: isLocalArtworkPath(uri),
    }));

  return candidates;
};

export const getImageProviderSync = (
  artwork?: ArtworkLike,
  fallback?: ArtworkLike,
  variant: ArtworkVariant = "card",
): ResolvedImageSource | undefined => {
  const candidate = getArtworkCandidates(artwork, fallback, variant)[0];
  return candidate ? { uri: candidate.uri } : undefined;
};

export const getDecodePixelSize = (size?: number) => {
  if (!size) {
    return undefined;
  }

  const pixels = Math.round(size * PixelRatio.get());
  return Math.max(48, Math.min(pixels, 1600));
};

export const getArtworkPalette = async (artwork?: ArtworkLike, category?: ArtworkCategory) => {
  const normalized = normalizeArtworkInput(artwork);
  if (normalized?.dominantColor) {
    return normalized.dominantColor;
  }

  switch (category) {
    case "artist":
      return "#20304A";
    case "playlist":
      return "#16283A";
    case "hero":
      return "#1A2940";
    case "album":
      return "#182638";
    case "track":
    default:
      return "#142235";
  }
};

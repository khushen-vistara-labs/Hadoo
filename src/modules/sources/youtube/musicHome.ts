import { logger } from "@/services/logger";
import type { HomeSection, MediaItem } from "@/types/home";
import type { Track } from "@/types/track";

import { buildScopedTrackId } from "@/modules/sources/sourceUtils";

const YT_MUSIC_URL = "https://music.youtube.com";
const YT_MUSIC_BROWSE_URL = `${YT_MUSIC_URL}/youtubei/v1/browse`;
const DEFAULT_CLIENT_VERSION = "1.20260707.01.00";

type Thumbnail = {
  url?: string;
  width?: number;
  height?: number;
};

type Run = {
  text?: string;
  navigationEndpoint?: Record<string, unknown>;
};

const extractTextRuns = (value: unknown): string | undefined => {
  if (!value || typeof value !== "object") {
    return undefined;
  }

  const candidate = value as { text?: string; runs?: Run[] };
  if (typeof candidate.text === "string" && candidate.text.trim()) {
    return candidate.text.trim();
  }

  if (Array.isArray(candidate.runs)) {
    const text = candidate.runs
      .map((run) => run.text?.trim())
      .filter(Boolean)
      .join("");

    return text || undefined;
  }

  return undefined;
};

const collectThumbnails = (value: unknown): Thumbnail[] => {
  if (!value || typeof value !== "object") {
    return [];
  }

  if (Array.isArray((value as { thumbnails?: Thumbnail[] }).thumbnails)) {
    return ((value as { thumbnails?: Thumbnail[] }).thumbnails ?? []).filter(Boolean);
  }

  if (Array.isArray(value)) {
    return value.flatMap(collectThumbnails);
  }

  return Object.values(value).flatMap(collectThumbnails);
};

const normalizeArtwork = (value: unknown) => {
  const thumbnails = collectThumbnails(value).filter((thumbnail) => typeof thumbnail.url === "string");
  if (!thumbnails.length) {
    return undefined;
  }

  const sorted = thumbnails.sort((left, right) => (left.width ?? 0) - (right.width ?? 0));
  const low = sorted[0]?.url;
  const standard = sorted[Math.floor(sorted.length / 2)]?.url ?? low;
  const high = sorted[sorted.length - 1]?.url ?? standard;

  if (!standard) {
    return undefined;
  }

  return {
    url: standard,
    urlLow: low,
    urlHigh: high,
    layout: "square" as const,
  };
};

const extractBrowseId = (endpoint?: Record<string, unknown>) =>
  typeof endpoint?.browseEndpoint === "object" &&
  endpoint.browseEndpoint &&
  typeof (endpoint.browseEndpoint as { browseId?: unknown }).browseId === "string"
    ? ((endpoint.browseEndpoint as { browseId: string }).browseId ?? undefined)
    : undefined;

const extractWatchPlaylistId = (endpoint?: Record<string, unknown>) =>
  typeof endpoint?.watchEndpoint === "object" &&
  endpoint.watchEndpoint &&
  typeof (endpoint.watchEndpoint as { playlistId?: unknown }).playlistId === "string"
    ? ((endpoint.watchEndpoint as { playlistId: string }).playlistId ?? undefined)
    : undefined;

const extractVideoId = (endpoint?: Record<string, unknown>) =>
  typeof endpoint?.watchEndpoint === "object" &&
  endpoint.watchEndpoint &&
  typeof (endpoint.watchEndpoint as { videoId?: unknown }).videoId === "string"
    ? ((endpoint.watchEndpoint as { videoId: string }).videoId ?? undefined)
    : undefined;

const extractRunsFromFlexColumn = (renderer: Record<string, unknown>) => {
  const columns = Array.isArray(renderer.flexColumns) ? renderer.flexColumns : [];
  return columns
    .map((column) => {
      const inner = column as { musicResponsiveListItemFlexColumnRenderer?: { text?: unknown } };
      return extractTextRuns(inner.musicResponsiveListItemFlexColumnRenderer?.text);
    })
    .filter(Boolean) as string[];
};

const deriveKindFromBrowseId = (browseId?: string): MediaItem["kind"] => {
  if (!browseId) {
    return "playlist";
  }

  if (browseId.startsWith("MPRE")) {
    return "album";
  }

  if (browseId.startsWith("UC") || browseId.startsWith("FEmusic_library_corpus_artist")) {
    return "artist";
  }

  return "playlist";
};

const mapResponsiveListItem = (renderer: Record<string, unknown>): MediaItem | undefined => {
  const runs = extractRunsFromFlexColumn(renderer);
  const firstRunEndpoint =
    ((renderer.flexColumns as Record<string, unknown>[] | undefined)?.[0] as
      | { musicResponsiveListItemFlexColumnRenderer?: { text?: { runs?: Run[] } } }
      | undefined)?.musicResponsiveListItemFlexColumnRenderer?.text?.runs?.[0]?.navigationEndpoint;

  const videoId = extractVideoId(firstRunEndpoint);
  const browseId = extractBrowseId(firstRunEndpoint);
  const playlistId = extractWatchPlaylistId(firstRunEndpoint);
  const title = runs[0];

  if (!title) {
    return undefined;
  }

  const artwork = normalizeArtwork(renderer.thumbnail);
  if (videoId) {
    const track: Track = {
      id: buildScopedTrackId("youtube_music_experimental", videoId),
      provider: "youtube_music_experimental",
      localId: videoId,
      providerTrackId: videoId,
      title,
      artist: runs[1] ?? "Unknown artist",
      artists: runs[1] ? [runs[1]] : undefined,
      album: runs[2],
      artwork: artwork?.urlHigh ?? artwork?.url,
      sourceUrl: `https://music.youtube.com/watch?v=${videoId}`,
    };

    return {
      id: track.id,
      provider: "youtube_music_experimental",
      kind: "track",
      title,
      subtitle: runs.slice(1).join(" • "),
      artwork,
      track,
      sourceUrl: track.sourceUrl,
      isPlayable: true,
    };
  }

  const kind = deriveKindFromBrowseId(browseId);
  return {
    id: browseId ?? playlistId ?? title,
    provider: "youtube_music_experimental",
    kind,
    title,
    subtitle: runs.slice(1).join(" • "),
    artwork,
    browseId,
    playlistId,
    albumId: kind === "album" ? browseId : undefined,
    artistId: kind === "artist" ? browseId : undefined,
    sourceUrl: playlistId ? `https://music.youtube.com/playlist?list=${playlistId}` : undefined,
    isPlayable: false,
  };
};

const extractTitleFromHeader = (header?: Record<string, unknown>) =>
  extractTextRuns((header?.musicCarouselShelfBasicHeaderRenderer as { title?: unknown } | undefined)?.title) ??
  extractTextRuns((header?.musicShelfRenderer as { title?: unknown } | undefined)?.title) ??
  extractTextRuns((header?.musicImmersiveHeaderRenderer as { title?: unknown } | undefined)?.title);

const extractSubtitleFromHeader = (header?: Record<string, unknown>) =>
  extractTextRuns((header?.musicCarouselShelfBasicHeaderRenderer as { strapline?: unknown } | undefined)?.strapline) ??
  extractTextRuns((header?.musicShelfRenderer as { subtitle?: unknown } | undefined)?.subtitle);

const mapTwoRowItem = (renderer: Record<string, unknown>): MediaItem | undefined => {
  const title =
    extractTextRuns(renderer.title) ??
    extractTextRuns(renderer.titleText) ??
    extractTextRuns(renderer.headline);

  if (!title) {
    return undefined;
  }

  const subtitle =
    extractTextRuns(renderer.subtitle) ??
    extractTextRuns(renderer.subtitleText) ??
    extractTextRuns(renderer.description);
  const browseId = extractBrowseId(renderer.navigationEndpoint as Record<string, unknown> | undefined);
  const playlistId = extractWatchPlaylistId(renderer.navigationEndpoint as Record<string, unknown> | undefined);
  const artwork = normalizeArtwork(renderer.thumbnailRenderer ?? renderer.thumbnail);
  const kind = deriveKindFromBrowseId(browseId);

  return {
    id: browseId ?? playlistId ?? title,
    provider: "youtube_music_experimental",
    kind,
    title,
    subtitle,
    artwork,
    browseId,
    playlistId,
    albumId: kind === "album" ? browseId : undefined,
    artistId: kind === "artist" ? browseId : undefined,
    sourceUrl: playlistId ? `https://music.youtube.com/playlist?list=${playlistId}` : undefined,
    isPlayable: false,
  };
};

const mapShelfContentItem = (item: unknown): MediaItem | undefined => {
  if (!item || typeof item !== "object") {
    return undefined;
  }

  const record = item as {
    musicResponsiveListItemRenderer?: Record<string, unknown>;
    musicTwoRowItemRenderer?: Record<string, unknown>;
  };

  if (record.musicResponsiveListItemRenderer) {
    return mapResponsiveListItem(record.musicResponsiveListItemRenderer);
  }

  if (record.musicTwoRowItemRenderer) {
    return mapTwoRowItem(record.musicTwoRowItemRenderer);
  }

  return undefined;
};

const findSectionListContents = (payload: Record<string, unknown>) => {
  const tabRenderer =
    (((payload.contents as Record<string, unknown> | undefined)?.singleColumnBrowseResultsRenderer as
      | { tabs?: { tabRenderer?: Record<string, unknown> }[] }
      | undefined)?.tabs ?? []).find((tab) => {
      const content = tab.tabRenderer?.content as Record<string, unknown> | undefined;
      return Boolean(content?.sectionListRenderer);
    })?.tabRenderer;

  return ((tabRenderer?.content as { sectionListRenderer?: { contents?: unknown[] } } | undefined)?.sectionListRenderer
    ?.contents ?? []) as unknown[];
};

const extractContinuationToken = (renderer: Record<string, unknown>) => {
  const continuations =
    (renderer.continuations as {
      nextContinuationData?: { continuation?: string };
    }[] | undefined) ?? [];

  return continuations[0]?.nextContinuationData?.continuation;
};

const mapCarouselShelf = (renderer: Record<string, unknown>, index: number): HomeSection | undefined => {
  const title = extractTitleFromHeader(renderer.header as Record<string, unknown> | undefined);
  const subtitle = extractSubtitleFromHeader(renderer.header as Record<string, unknown> | undefined);
  const items = ((renderer.contents as unknown[]) ?? []).map(mapShelfContentItem).filter(Boolean) as MediaItem[];

  if (!title || !items.length) {
    return undefined;
  }

  const trackCount = items.filter((item) => item.kind === "track").length;
  return {
    id: `ytm-carousel-${index}-${title}`,
    provider: "youtube_music_experimental",
    title,
    subtitle,
    cardType: trackCount >= Math.ceil(items.length / 2) ? "track_list" : "media_grid",
    items,
    continuationToken: extractContinuationToken(renderer),
  };
};

const mapShelf = (renderer: Record<string, unknown>, index: number): HomeSection | undefined => {
  const title = extractTitleFromHeader(renderer.header as Record<string, unknown> | undefined);
  const subtitle = extractSubtitleFromHeader(renderer.header as Record<string, unknown> | undefined);
  const items = ((renderer.contents as unknown[]) ?? []).map(mapShelfContentItem).filter(Boolean) as MediaItem[];

  if (!title || !items.length) {
    return undefined;
  }

  return {
    id: `ytm-shelf-${index}-${title}`,
    provider: "youtube_music_experimental",
    title,
    subtitle,
    cardType: "track_list",
    items,
    continuationToken: extractContinuationToken(renderer),
  };
};

export const fetchYouTubeMusicHomeSections = async (): Promise<HomeSection[]> => {
  const response = await fetch(`${YT_MUSIC_BROWSE_URL}?prettyPrint=false`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "accept-language": "en-US,en;q=0.9",
    },
    body: JSON.stringify({
      context: {
        client: {
          clientName: "WEB_REMIX",
          clientVersion: DEFAULT_CLIENT_VERSION,
          hl: "en",
          gl: "US",
        },
        user: {},
      },
      browseId: "FEmusic_home",
    }),
  });

  if (!response.ok) {
    throw new Error(`YouTube Music browse failed with ${response.status}`);
  }

  const payload = (await response.json()) as Record<string, unknown>;
  const sections = findSectionListContents(payload)
    .map((item, index) => {
      const renderer = item as {
        musicCarouselShelfRenderer?: Record<string, unknown>;
        musicShelfRenderer?: Record<string, unknown>;
      };

      if (renderer.musicCarouselShelfRenderer) {
        return mapCarouselShelf(renderer.musicCarouselShelfRenderer, index);
      }

      if (renderer.musicShelfRenderer) {
        return mapShelf(renderer.musicShelfRenderer, index);
      }

      return undefined;
    })
    .filter(Boolean) as HomeSection[];

  logger.info("YouTube Music home: response sectionList entries", findSectionListContents(payload).length);
  logger.info("YouTube Music home: normalized sections", sections.length);
  return sections;
};

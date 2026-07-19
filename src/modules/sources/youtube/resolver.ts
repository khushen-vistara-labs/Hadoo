import { logger } from "@/services/logger";
import type { StreamSource, TrackQuality } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

import { pipedYouTubeClient } from "@/modules/sources/PipedYouTubeClient";
import { extractExpiresAt, resolveCipheredUrl } from "@/modules/sources/youtube/cipher";
import {
  fetchInnertubePlayerResponses,
  type CLIENT_PROFILES,
  type YouTubePlayerResponse,
} from "@/modules/sources/youtube/innertube";
import { fetchYouTubePlayerJs } from "@/modules/sources/youtube/playerJs";
import { fetchYouTubeWatchPage } from "@/modules/sources/youtube/watchPage";

type NormalizedTrackDetails = {
  id: string;
  title: string;
  author?: string;
  durationSeconds?: number;
  thumbnailUrl?: string;
  sourceUrl: string;
};

type ResolvedStream = StreamSource & {
  bitrate?: number;
  container?: string;
  codec?: string;
};

type InnertubeClientProfile = (typeof CLIENT_PROFILES)[number];

const mapBitrateToQuality = (bitrate?: number): TrackQuality => {
  if (!bitrate) {
    return "unknown";
  }

  if (bitrate >= 256_000) {
    return "lossless";
  }

  if (bitrate >= 160_000) {
    return "high";
  }

  if (bitrate >= 96_000) {
    return "medium";
  }

  return "low";
};

const parseMimeType = (mimeType?: string) => {
  if (!mimeType) {
    return {};
  }

  const [containerPart, codecPart] = mimeType.split(";");
  const container = containerPart.split("/")[1]?.trim();
  const codec = codecPart?.match(/codecs="([^"]+)"/)?.[1];

  return {
    container,
    codec,
  };
};

const getBestThumbnail = (response?: YouTubePlayerResponse) =>
  response?.videoDetails?.thumbnail?.thumbnails?.[response.videoDetails.thumbnail.thumbnails.length - 1]?.url;

const collectFormats = (response: YouTubePlayerResponse) => [
  ...(response.streamingData?.adaptiveFormats ?? []),
  ...(response.streamingData?.formats ?? []),
];

const isAudioFormat = (format: Record<string, unknown>) => {
  const mimeType = typeof format.mimeType === "string" ? format.mimeType : "";
  return mimeType.startsWith("audio/") || typeof format.audioQuality === "string";
};

const normalizeStream = (
  format: Record<string, unknown>,
  client: InnertubeClientProfile,
  decipher?: (value: string) => string,
): ResolvedStream | undefined => {
  logger.info(
    "YouTube resolver: fmt",
    format.itag ?? "unknown",
    typeof format.mimeType === "string" ? format.mimeType : "unknown",
    "hasUrl",
    Boolean(format.url),
    "hasCipher",
    Boolean(format.signatureCipher) || Boolean(format.cipher),
  );

  const url = resolveCipheredUrl(
    typeof format.url === "string" ? format.url : undefined,
    typeof format.signatureCipher === "string" ? format.signatureCipher : undefined,
    typeof format.cipher === "string" ? format.cipher : undefined,
    decipher,
  );

  if (!url) {
    return undefined;
  }

  const bitrate = typeof format.bitrate === "number" ? format.bitrate : undefined;
  const mimeType = typeof format.mimeType === "string" ? format.mimeType : undefined;
  const parsedMime = parseMimeType(mimeType);

  return {
    url,
    bitrate,
    quality: mapBitrateToQuality(bitrate),
    format: parsedMime.container,
    mimeType,
    container: parsedMime.container,
    codec: parsedMime.codec,
    expiresAt: extractExpiresAt(url),
    headers: {
      "User-Agent": client.userAgent,
      Origin: "https://www.youtube.com",
      Referer: "https://www.youtube.com/",
    },
  };
};

const chooseBestPlayerResponse = (
  responses: { client: InnertubeClientProfile; payload: YouTubePlayerResponse }[],
) =>
  responses.find(
    (item) =>
      item.payload.playabilityStatus?.status === "OK" && collectFormats(item.payload).some(isAudioFormat),
  ) ??
  responses.find((item) => item.payload.playabilityStatus?.status === "OK") ??
  responses.find((item) => collectFormats(item.payload).some(isAudioFormat)) ??
  responses[0];

export const youtubeResolver = {
  async getTrackDetails(videoId: string): Promise<NormalizedTrackDetails> {
    logger.info("YouTube resolver: watch page", videoId);
    const watchPage = await fetchYouTubeWatchPage(videoId);
    logger.info("YouTube resolver: player JS", watchPage.playerUrl ?? "missing");
    const playerJs = await fetchYouTubePlayerJs(watchPage.playerUrl);
    logger.info("YouTube resolver: innertube player", videoId, playerJs.signatureTimestamp);
    const responses = await fetchInnertubePlayerResponses(watchPage, videoId, playerJs.signatureTimestamp);
    const selectedResponse = chooseBestPlayerResponse(responses);
    const payload = selectedResponse?.payload ?? watchPage.initialPlayerResponse;

    const videoDetails = payload?.videoDetails as YouTubePlayerResponse["videoDetails"] | undefined;
    if (!videoDetails?.title) {
      throw new StreamResolveError("YouTube track details could not be resolved.");
  }

  return {
      id: videoDetails.videoId ?? videoId,
      title: videoDetails.title,
      author: videoDetails.author,
      durationSeconds: Number(videoDetails.lengthSeconds ?? 0) || undefined,
      thumbnailUrl: getBestThumbnail(payload as YouTubePlayerResponse),
      sourceUrl: `https://www.youtube.com/watch?v=${videoId}`,
    };
  },

  async getStreams(videoId: string): Promise<ResolvedStream[]> {
    let primaryError: unknown;

    try {
      logger.info("YouTube resolver: watch page", videoId);
      const watchPage = await fetchYouTubeWatchPage(videoId);
      logger.info("YouTube resolver: player JS", watchPage.playerUrl ?? "missing");
      const playerJs = await fetchYouTubePlayerJs(watchPage.playerUrl);
      logger.info("YouTube resolver: innertube player", videoId, playerJs.signatureTimestamp);
      const responses = await fetchInnertubePlayerResponses(watchPage, videoId, playerJs.signatureTimestamp);
      const selectedResponse = chooseBestPlayerResponse(responses);
      const client = selectedResponse?.client;
      const payload = selectedResponse?.payload;

      if (!payload) {
        throw new StreamResolveError("YouTube player response did not contain any usable payloads.");
      }
      if (!client) {
        throw new StreamResolveError("YouTube player response did not retain client context.");
      }

      const playabilityStatus = payload.playabilityStatus?.status;
      if (playabilityStatus && playabilityStatus !== "OK") {
        throw new StreamResolveError(
          payload.playabilityStatus?.reason ?? `YouTube player returned ${playabilityStatus}.`,
        );
      }

      const audioFormats = collectFormats(payload).filter(isAudioFormat);
      logger.info("YouTube resolver: audio format candidates", videoId, audioFormats.length);

      const streams = audioFormats
        .map((format) => normalizeStream(format, client, playerJs.decipher))
        .filter(Boolean) as ResolvedStream[];

      logger.info("YouTube resolver: deciphered audio streams", videoId, streams.length);

      if (!streams.length) {
        throw new StreamResolveError("No playable YouTube audio streams were returned.");
      }

      const sorted = streams.sort((left, right) => (right.bitrate ?? 0) - (left.bitrate ?? 0));
      logger.info("YouTube resolver: selected stream", sorted[0]?.url?.slice(0, 120) ?? "missing");
      logger.info("YouTube resolver: selected stream headers", sorted[0]?.headers ?? {});
      return sorted;
    } catch (error) {
      primaryError = error;
      logger.warn("YouTube Innertube stream resolution failed; trying Piped", videoId, error);
    }

    try {
      const payload = await pipedYouTubeClient.getStreams(videoId);
      const streams = (payload.audioStreams ?? [])
        .filter((stream) => /^https?:\/\//i.test(stream.url))
        .map((stream) => ({
          url: stream.url,
          bitrate: stream.bitrate,
          quality: mapBitrateToQuality(stream.bitrate),
          format: stream.format,
          mimeType: stream.mimeType,
          codec: stream.codec,
          expiresAt: extractExpiresAt(stream.url),
        } satisfies ResolvedStream))
        .sort((left, right) => (right.bitrate ?? 0) - (left.bitrate ?? 0));

      if (streams.length) {
        logger.info("YouTube resolver: Piped audio stream fallback", videoId, streams.length);
        return streams;
      }
    } catch (fallbackError) {
      logger.warn("YouTube Piped stream fallback failed", videoId, fallbackError);
    }

    if (primaryError instanceof Error) {
      throw primaryError;
    }
    throw new StreamResolveError("No playable YouTube audio streams were returned.");
  },
};

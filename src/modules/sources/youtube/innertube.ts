import { logger } from "@/services/logger";

import type { YouTubeWatchPage } from "@/modules/sources/youtube/watchPage";

type ClientProfile = {
  clientName: "TVHTML5" | "IOS" | "ANDROID_VR";
  clientVersion: string;
  userAgent: string;
};

export const CLIENT_PROFILES: ClientProfile[] = [
  {
    clientName: "ANDROID_VR",
    clientVersion: "1.71.26",
    userAgent: "com.google.android.apps.youtube.vr.oculus/1.71.26 (Linux; U; Android 14)",
  },
  {
    clientName: "TVHTML5",
    clientVersion: "7.20250601.18.00",
    userAgent: "Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version",
  },
  {
    clientName: "IOS",
    clientVersion: "20.10.4",
    userAgent: "com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3 like Mac OS X)",
  },
];

export type YouTubePlayerResponse = {
  playabilityStatus?: {
    status?: string;
    reason?: string;
  };
  videoDetails?: {
    videoId?: string;
    title?: string;
    author?: string;
    lengthSeconds?: string;
    thumbnail?: {
      thumbnails?: { url: string; width?: number; height?: number }[];
    };
  };
  streamingData?: {
    adaptiveFormats?: Record<string, unknown>[];
    formats?: Record<string, unknown>[];
  };
};

const postPlayerRequest = async (
  apiKey: string,
  watchPage: YouTubeWatchPage,
  videoId: string,
  signatureTimestamp: number | undefined,
  client: ClientProfile,
) => {
  const response = await fetch(`https://www.youtube.com/youtubei/v1/player?prettyPrint=false&key=${apiKey}`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "accept-language": "en-US,en;q=0.9",
      "x-goog-visitor-id": watchPage.visitorData ?? "",
      "user-agent": client.userAgent,
    },
    body: JSON.stringify({
      videoId,
      context: {
        client: {
          clientName: client.clientName,
          clientVersion: client.clientVersion,
          hl: "en",
          gl: "US",
        },
      },
      playbackContext: {
        contentPlaybackContext: {
          signatureTimestamp,
        },
      },
      contentCheckOk: true,
      racyCheckOk: true,
    }),
  });

  logger.info("YouTube resolver: innertube response status", client.clientName, response.status);

  if (!response.ok) {
    throw new Error(`Innertube player request failed with ${response.status} for ${client.clientName}`);
  }

  const payload = (await response.json()) as YouTubePlayerResponse;

  logger.info(
    "YouTube resolver: playability",
    client.clientName,
    payload.playabilityStatus?.status ?? "unknown",
    payload.playabilityStatus?.reason ?? "",
  );
  logger.info(
    "YouTube resolver: streamingData",
    client.clientName,
    Boolean(payload.streamingData),
    "adaptiveFormats",
    payload.streamingData?.adaptiveFormats?.length ?? 0,
    "formats",
    payload.streamingData?.formats?.length ?? 0,
  );

  return payload;
};

export const fetchInnertubePlayerResponses = async (
  watchPage: YouTubeWatchPage,
  videoId: string,
  signatureTimestamp?: number,
) => {
  if (!watchPage.apiKey) {
    throw new Error("YouTube watch page did not expose an Innertube API key.");
  }

  const responses: { client: ClientProfile; payload: YouTubePlayerResponse }[] = [];
  let lastError: Error | undefined;

  for (const client of CLIENT_PROFILES) {
    try {
      const payload = await postPlayerRequest(watchPage.apiKey, watchPage, videoId, signatureTimestamp, client);
      responses.push({ client, payload });
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
    }
  }

  if (!responses.length && lastError) {
    throw lastError;
  }

  return responses;
};

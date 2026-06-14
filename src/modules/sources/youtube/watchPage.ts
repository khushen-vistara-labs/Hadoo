const WATCH_PAGE_URL = "https://www.youtube.com/watch";

const decodeJsPath = (value: string) =>
  value
    .replace(/\\\//g, "/")
    .replace(/\u0026/g, "&")
    .replace(/\\u0026/g, "&");

const findQuotedValue = (html: string, pattern: RegExp) => {
  const match = html.match(pattern);
  return match?.[1];
};

const extractJsonObject = (source: string, marker: string) => {
  const markerIndex = source.indexOf(marker);
  if (markerIndex < 0) {
    return undefined;
  }

  const start = source.indexOf("{", markerIndex);
  if (start < 0) {
    return undefined;
  }

  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = start; index < source.length; index += 1) {
    const char = source[index];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }

    if (char === '"') {
      inString = true;
      continue;
    }

    if (char === "{") {
      depth += 1;
    } else if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        return source.slice(start, index + 1);
      }
    }
  }

  return undefined;
};

export type YouTubeWatchPage = {
  html: string;
  playerUrl?: string;
  apiKey?: string;
  clientVersion?: string;
  visitorData?: string;
  initialPlayerResponse?: Record<string, unknown>;
};

export const fetchYouTubeWatchPage = async (videoId: string): Promise<YouTubeWatchPage> => {
  const params = new URLSearchParams({
    v: videoId,
    bpctr: "9999999999",
    has_verified: "1",
    hl: "en",
  });

  const response = await fetch(`${WATCH_PAGE_URL}?${params.toString()}`, {
    headers: {
      accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "accept-language": "en-US,en;q=0.9",
    },
  });

  if (!response.ok) {
    throw new Error(`YouTube watch page request failed with ${response.status}`);
  }

  const html = await response.text();
  const playerPath =
    findQuotedValue(html, /"jsUrl":"([^"]+)"/) ??
    findQuotedValue(html, /"PLAYER_JS_URL":"([^"]+)"/) ??
    findQuotedValue(html, /"js":"([^"]*\/base\.js)"/);

  const playerUrl = playerPath
    ? `https://www.youtube.com${decodeJsPath(playerPath).startsWith("/") ? decodeJsPath(playerPath) : `/${decodeJsPath(playerPath)}`}`
    : undefined;

  const apiKey =
    findQuotedValue(html, /"INNERTUBE_API_KEY":"([^"]+)"/) ??
    findQuotedValue(html, /innertubeApiKey":"([^"]+)"/);

  const clientVersion =
    findQuotedValue(html, /"INNERTUBE_CLIENT_VERSION":"([^"]+)"/) ??
    findQuotedValue(html, /innertubeClientVersion":"([^"]+)"/);

  const visitorData = findQuotedValue(html, /"VISITOR_DATA":"([^"]+)"/);

  const initialPlayerResponseRaw =
    extractJsonObject(html, "var ytInitialPlayerResponse =") ??
    extractJsonObject(html, "ytInitialPlayerResponse =") ??
    extractJsonObject(html, '"playerResponse":');

  let initialPlayerResponse: Record<string, unknown> | undefined;
  if (initialPlayerResponseRaw) {
    try {
      initialPlayerResponse = JSON.parse(initialPlayerResponseRaw) as Record<string, unknown>;
    } catch {
      initialPlayerResponse = undefined;
    }
  }

  return {
    html,
    playerUrl,
    apiKey,
    clientVersion,
    visitorData,
    initialPlayerResponse,
  };
};

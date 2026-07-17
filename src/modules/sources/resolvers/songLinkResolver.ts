import { fetchDeezerIsrcFromUrl, fetchDeezerTrackByIsrc } from "@/modules/sources/resolvers/deezerResolver";

type ResolvedProviderLinks = {
  isrc?: string;
  tidalUrl?: string;
  amazonUrl?: string;
  deezerUrl?: string;
};

const normalizeAmazonUrl = (url?: string) => {
  if (!url) {
    return undefined;
  }
  return url.replace(/^http:\/\//i, "https://");
};

const scrapeNextData = async (url: string) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Song.link request failed with ${response.status}`);
  }
  const html = await response.text();
  const match = html.match(/<script id="__NEXT_DATA__" type="application\/json">(.*?)<\/script>/is);
  if (!match?.[1]) {
    throw new Error("Song.link payload was missing __NEXT_DATA__.");
  }
  return JSON.parse(match[1]) as {
    props?: {
      pageProps?: {
        pageData?: {
          entityData?: { isrc?: string };
          sections?: Array<{ links?: Array<{ platform?: string; url?: string }> }>;
        };
      };
    };
  };
};

const parseLinks = (payload: Awaited<ReturnType<typeof scrapeNextData>>): ResolvedProviderLinks => {
  const pageData = payload.props?.pageProps?.pageData;
  const links = pageData?.sections?.flatMap((section) => section.links ?? []) ?? [];
  const findPlatform = (platform: string) => links.find((link) => link.platform === platform)?.url;

  return {
    isrc: pageData?.entityData?.isrc?.trim(),
    tidalUrl: findPlatform("tidal"),
    amazonUrl: normalizeAmazonUrl(findPlatform("amazon")),
    deezerUrl: findPlatform("deezer"),
  };
};

export const resolveSongLinkProviders = async (spotifyTrackId: string, knownIsrc?: string): Promise<ResolvedProviderLinks> => {
  const primary = parseLinks(await scrapeNextData(`https://song.link/s/${encodeURIComponent(spotifyTrackId)}`));
  if (primary.tidalUrl || primary.amazonUrl) {
    return primary;
  }

  const resolvedIsrc = primary.isrc || knownIsrc;
  const deezerUrl =
    primary.deezerUrl ||
    (resolvedIsrc ? (await fetchDeezerTrackByIsrc(resolvedIsrc).catch(() => undefined))?.link : undefined);

  if (!deezerUrl) {
    return primary;
  }

  const deezerTrackId = deezerUrl.match(/\/track\/(\d+)/)?.[1];
  if (!deezerTrackId) {
    return {
      ...primary,
      deezerUrl,
      isrc: primary.isrc || (await fetchDeezerIsrcFromUrl(deezerUrl)),
    };
  }

  const secondary = parseLinks(await scrapeNextData(`https://song.link/d/${encodeURIComponent(deezerTrackId)}`));
  return {
    isrc: primary.isrc || secondary.isrc,
    tidalUrl: primary.tidalUrl || secondary.tidalUrl,
    amazonUrl: primary.amazonUrl || secondary.amazonUrl,
    deezerUrl,
  };
};

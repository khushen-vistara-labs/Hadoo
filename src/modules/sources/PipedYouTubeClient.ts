const INVIDIOUS_SEARCH_BASE_URLS = ["https://yt.chocolatemoo53.com"];

const PIPED_BASE_URLS = ["https://pipedapi.kavin.rocks"];

const normalizeThumbnailUrl = (url?: string) => {
  if (!url) {
    return undefined;
  }

  if (url.startsWith("http://") || url.startsWith("https://")) {
    return url;
  }

  if (url.startsWith("//")) {
    return `https:${url}`;
  }

  if (url.startsWith("/vi/")) {
    return `https://i.ytimg.com${url}`;
  }

  return url;
};

type PipedAudioStream = {
  url: string;
  bitrate?: number;
  codec?: string;
  format?: string;
  mimeType?: string;
  quality?: string;
};

type PipedRelatedStream = {
  title: string;
  url: string;
  duration?: number;
  thumbnail?: string;
  uploader?: string;
};

type InvidiousSearchResult = {
  type?: string;
  title: string;
  videoId?: string;
  videoThumbnails?: { url: string }[];
  author?: string;
  lengthSeconds?: number;
};

export type PipedSearchResult = {
  type?: string;
  title: string;
  url: string;
  duration?: number;
  thumbnail?: string;
  uploaderName?: string;
  uploader?: string;
  uploaderUrl?: string;
};

export type PipedStreamsResponse = {
  title: string;
  duration?: number;
  thumbnailUrl?: string;
  uploader?: string;
  uploaderUrl?: string;
  audioStreams?: PipedAudioStream[];
  relatedStreams?: PipedRelatedStream[];
};

export type PipedPlaylistResponse = {
  name: string;
  bannerUrl?: string;
  relatedStreams?: PipedRelatedStream[];
};

const fetchJsonFromBases = async <T>(bases: string[], path: string, errorLabel: string): Promise<T> => {
  let lastError: Error | undefined;

  for (const baseUrl of bases) {
    try {
      const response = await fetch(`${baseUrl}${path}`);
      if (!response.ok) {
        throw new Error(`${errorLabel} request failed with ${response.status} from ${baseUrl}`);
      }

      return (await response.json()) as T;
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
    }
  }

  throw lastError ?? new Error(`${errorLabel} request failed.`);
};

export const pipedYouTubeClient = {
  async search(query: string) {
    const params = new URLSearchParams({
      q: query,
      type: "video",
    });

    const results = await fetchJsonFromBases<InvidiousSearchResult[]>(
      INVIDIOUS_SEARCH_BASE_URLS,
      `/api/v1/search?${params.toString()}`,
      "YouTube search",
    );

    return results.map((item) => ({
      type: item.type,
      title: item.title,
      url: item.videoId ? `/watch?v=${item.videoId}` : "",
      duration: item.lengthSeconds,
      thumbnail: normalizeThumbnailUrl(item.videoThumbnails?.[item.videoThumbnails.length - 1]?.url),
      uploaderName: item.author,
    }));
  },

  getStreams(videoId: string) {
    return fetchJsonFromBases<PipedStreamsResponse>(
      PIPED_BASE_URLS,
      `/streams/${encodeURIComponent(videoId)}`,
      "YouTube stream",
    );
  },

  getPlaylist(playlistId: string) {
    return fetchJsonFromBases<PipedPlaylistResponse>(
      PIPED_BASE_URLS,
      `/playlists/${encodeURIComponent(playlistId)}`,
      "YouTube playlist",
    );
  },
};

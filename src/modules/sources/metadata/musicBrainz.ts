import { logger } from "@/services/logger";

type MusicBrainzResponse = {
  recordings?: Array<{
    tags?: Array<{ name?: string; count?: number }>;
  }>;
};

export const fetchMusicBrainzGenres = async (isrc?: string) => {
  if (!isrc) {
    return [];
  }

  try {
    const params = new URLSearchParams({
      query: `isrc:${isrc}`,
      fmt: "json",
      inc: "tags",
    });
    const response = await fetch(`https://musicbrainz.org/ws/2/recording?${params.toString()}`, {
      headers: {
        accept: "application/json",
        "user-agent": "Hadoo/0.1",
      },
    });

    if (!response.ok) {
      return [];
    }

    const payload = (await response.json()) as MusicBrainzResponse;
    const tags = payload.recordings?.[0]?.tags ?? [];
    return tags
      .sort((left, right) => (right.count ?? 0) - (left.count ?? 0))
      .slice(0, 5)
      .map((tag) => tag.name?.trim())
      .filter(Boolean) as string[];
  } catch (error) {
    logger.warn("MusicBrainz lookup failed", error);
    return [];
  }
};

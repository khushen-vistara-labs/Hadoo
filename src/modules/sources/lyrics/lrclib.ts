import type { LyricLine, Track } from "@/types/track";

type LrclibResponse = {
  plainLyrics?: string;
  syncedLyrics?: string;
};

const parseLyrics = (payload: LrclibResponse): LyricLine[] => {
  const source = payload.syncedLyrics || payload.plainLyrics || "";
  if (!source) {
    return [];
  }

  return source
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const match = line.match(/^\[(\d+):(\d+)\.(\d+)\](.*)$/);
      if (!match) {
        return { text: line };
      }

      const minutes = Number(match[1] ?? 0);
      const seconds = Number(match[2] ?? 0);
      const centiseconds = Number(match[3] ?? 0);
      return {
        time: minutes * 60_000 + seconds * 1_000 + centiseconds * 10,
        text: (match[4] ?? "").trim(),
      };
    });
};

const fetchJson = async <T>(url: string) => {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`LRCLIB request failed with ${response.status}`);
  }
  return (await response.json()) as T;
};

const simplifyTrackName = (name: string) => {
  const withoutParen = name.includes("(") ? name.slice(0, name.indexOf("(")).trim() : name;
  return withoutParen.includes(" - ") ? withoutParen.slice(0, withoutParen.indexOf(" - ")).trim() : withoutParen;
};

export const fetchLyricsFromLrclib = async (track: Track): Promise<LyricLine[]> => {
  const attempts: string[] = [];
  const addGetAttempt = (title: string, includeAlbum: boolean) => {
    const params = new URLSearchParams({
      artist_name: track.artist,
      track_name: title,
    });
    if (includeAlbum && track.album) {
      params.set("album_name", track.album);
    }
    if (track.duration) {
      params.set("duration", String(Math.round(track.duration)));
    }
    attempts.push(`https://lrclib.net/api/get?${params.toString()}`);
  };

  addGetAttempt(track.title, true);
  addGetAttempt(track.title, false);
  const simplified = simplifyTrackName(track.title);
  if (simplified && simplified !== track.title) {
    addGetAttempt(simplified, false);
  }

  for (const url of attempts) {
    try {
      const payload = await fetchJson<LrclibResponse>(url);
      const parsed = parseLyrics(payload);
      if (parsed.length) {
        return parsed;
      }
    } catch {}
  }

  const searchTerms = [track.title, simplified].filter(Boolean);
  for (const title of searchTerms) {
    try {
      const params = new URLSearchParams({
        artist_name: track.artist,
        track_name: title,
      });
      const payload = await fetchJson<LrclibResponse[]>(`https://lrclib.net/api/search?${params.toString()}`);
      for (const result of payload) {
        const parsed = parseLyrics(result);
        if (parsed.length) {
          return parsed;
        }
      }
    } catch {}
  }

  return [{ text: "Lyrics are not available for this track yet." }];
};

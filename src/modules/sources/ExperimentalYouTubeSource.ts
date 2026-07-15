import type { MusicSource } from "@/modules/sources/MusicSource";
import { pipedYouTubeClient } from "@/modules/sources/PipedYouTubeClient";
import type { ImportResult } from "@/modules/sources/sourceModels";
import { buildScopedTrackId } from "@/modules/sources/sourceUtils";
import { youtubeResolver } from "@/modules/sources/youtube/resolver";
import { extractYouTubePlaylistId, extractYouTubeVideoId, isYouTubeUrl } from "@/modules/sources/youtubeUrl";
import type { StreamSource, Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

export class ExperimentalYouTubeSource implements MusicSource {
  id = "youtube_experimental" as const;
  name = "YouTube Experimental";
  status = "enabled" as const;

  canHandleUrl(url: string) {
    return Boolean(extractYouTubeVideoId(url));
  }

  canImportUrl(url: string) {
    return Boolean(extractYouTubePlaylistId(url));
  }

  async search(query: string): Promise<Track[]> {
    const trimmed = query.trim();
    if (!trimmed) {
      return [];
    }

    if (isYouTubeUrl(trimmed)) {
      const videoId = extractYouTubeVideoId(trimmed);
      if (videoId) {
        return [await this.getTrackDetails(videoId)];
      }

      const imported = await this.importFromUrl(trimmed);
      return imported.tracks;
    }

    const results = await pipedYouTubeClient.search(trimmed);

    return results
      .map((item) => {
        const localId = extractYouTubeVideoId(`https://www.youtube.com${item.url}`);
        if (!localId) {
          return undefined;
        }

        return {
          id: buildScopedTrackId(this.id, localId),
          provider: this.id,
          localId,
          title: item.title,
          artist: item.uploaderName ?? "Unknown artist",
          artists: item.uploaderName ? [item.uploaderName] : undefined,
          artwork: item.thumbnail,
          duration: item.duration,
          sourceUrl: `https://www.youtube.com/watch?v=${localId}`,
          providerTrackId: localId,
        } satisfies Track;
      })
      .filter(Boolean) as Track[];
  }

  async resolveTrackFromUrl(url: string): Promise<Track> {
    const videoId = extractYouTubeVideoId(url);
    if (!videoId) {
      throw new SourceUnavailableError("This YouTube link could not be parsed.");
    }

    return this.getTrackDetails(videoId);
  }

  async getTrackDetails(localId: string): Promise<Track> {
    const payload = await youtubeResolver.getTrackDetails(localId);

    return {
      id: buildScopedTrackId(this.id, localId),
      provider: this.id,
      localId,
      title: payload.title,
      artist: payload.author ?? "Unknown artist",
      artists: payload.author ? [payload.author] : undefined,
      artwork: payload.thumbnailUrl,
      duration: payload.durationSeconds,
      sourceUrl: `https://www.youtube.com/watch?v=${localId}`,
      providerTrackId: localId,
    };
  }

  async getStreams(localId: string): Promise<StreamSource[]> {
    return youtubeResolver.getStreams(localId);
  }

  async importFromUrl(url: string): Promise<ImportResult> {
    const playlistId = extractYouTubePlaylistId(url);
    if (!playlistId) {
      throw new SourceUnavailableError("This YouTube playlist link could not be parsed.");
    }

    const payload = await pipedYouTubeClient.getPlaylist(playlistId);
    const tracks = (payload.relatedStreams ?? [])
      .map((item) => {
        const localId = extractYouTubeVideoId(`https://www.youtube.com${item.url}`);
        if (!localId) {
          return undefined;
        }

        return {
          id: buildScopedTrackId(this.id, localId),
          provider: this.id,
          localId,
          title: item.title,
          artist: item.uploader ?? "Unknown artist",
          artists: item.uploader ? [item.uploader] : undefined,
          artwork: item.thumbnail,
          duration: item.duration,
          sourceUrl: `https://www.youtube.com/watch?v=${localId}&list=${playlistId}`,
          providerTrackId: localId,
        } satisfies Track;
      })
      .filter(Boolean) as Track[];

    return {
      collection: {
        id: `${this.id}::playlist::${playlistId}`,
        title: payload.name,
        sourceUrl: url,
        artwork: payload.bannerUrl,
      },
      tracks,
    };
  }

  async getLyrics(_track: Track) {
    return [{ text: "Lyrics are not available for this source yet." }];
  }
}

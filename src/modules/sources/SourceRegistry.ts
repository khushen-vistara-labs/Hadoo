import { CachedMusicSource } from "@/modules/sources/CachedMusicSource";
import { ExperimentalJioSaavnSource } from "@/modules/sources/ExperimentalJioSaavnSource";
import { ExperimentalYouTubeMusicSource } from "@/modules/sources/ExperimentalYouTubeMusicSource";
import { LocalFilesMusicSource } from "@/modules/sources/LocalFilesMusicSource";
import type { MusicSource } from "@/modules/sources/MusicSource";
import { MockMusicSource } from "@/modules/sources/MockMusicSource";
import { extractScopedLocalId, isProbablyUrl, selectPreferredStream } from "@/modules/sources/sourceUtils";
import { logger } from "@/services/logger";
import type { AudioQualityPreference, MusicProvider, ProviderStatus } from "@/types/source";
import type { ImportResult } from "@/modules/sources/sourceModels";
import type { StreamResult, Track } from "@/types/track";
import { SourceUnavailableError, StreamResolveError } from "@/utils/errors";

type ProviderHealth = {
  provider: MusicProvider;
  status: ProviderStatus;
  error?: string;
};

export class SourceRegistry {
  private sources = new Map<MusicProvider, MusicSource>();
  private enabled = new Set<MusicProvider>();

  constructor() {
    [
      new MockMusicSource(),
      new LocalFilesMusicSource(),
      new ExperimentalYouTubeMusicSource(),
      new ExperimentalJioSaavnSource(),
      new CachedMusicSource(),
    ].forEach((source) => this.register(source));
  }

  register(source: MusicSource) {
    this.sources.set(source.id, source);
    if (source.status !== "disabled") {
      this.enabled.add(source.id);
    }
  }

  setProviderEnabled(provider: MusicProvider, enabled: boolean) {
    if (enabled) {
      this.enabled.add(provider);
      return;
    }
    this.enabled.delete(provider);
  }

  getProvider(provider: MusicProvider) {
    return this.sources.get(provider);
  }

  getStatuses(): ProviderHealth[] {
    return [...this.sources.values()].map((source) => ({
      provider: source.id,
      status: this.enabled.has(source.id) ? source.status : "disabled",
    }));
  }

  async search(query: string, provider: MusicProvider | "all" = "all") {
    const trimmed = query.trim();
    if (isProbablyUrl(trimmed)) {
      const tracks = await this.resolveUrlIntent(trimmed, provider);
      return tracks;
    }

    const candidates =
      provider === "all"
        ? [...this.sources.values()].filter((source) => this.enabled.has(source.id))
        : [this.sources.get(provider)].filter(Boolean) as MusicSource[];

    const settled = await Promise.allSettled(
      candidates.map(async (source) => {
        const tracks = await source.search(query);
        return tracks.map((track) => ({ ...track, provider: source.id }));
      }),
    );

    const tracks: Track[] = [];

    settled.forEach((result, index) => {
      if (result.status === "fulfilled") {
        tracks.push(...result.value);
        return;
      }

      logger.warn("Provider search failed", candidates[index]?.id, result.reason);
    });

    return tracks;
  }

  async resolveUrlIntent(url: string, provider: MusicProvider | "all" = "all"): Promise<Track[]> {
    const candidates =
      provider === "all"
        ? [...this.sources.values()].filter((source) => this.enabled.has(source.id))
        : [this.sources.get(provider)].filter(Boolean) as MusicSource[];

    for (const source of candidates) {
      if (source.canHandleUrl?.(url) && source.resolveTrackFromUrl) {
        return [await source.resolveTrackFromUrl(url)];
      }

      if (source.canImportUrl?.(url) && source.importFromUrl) {
        const imported = await source.importFromUrl(url);
        return imported.tracks;
      }
    }

    return [];
  }

  async importFromUrl(url: string, provider: MusicProvider | "all" = "all"): Promise<ImportResult | undefined> {
    const candidates =
      provider === "all"
        ? [...this.sources.values()].filter((source) => this.enabled.has(source.id))
        : [this.sources.get(provider)].filter(Boolean) as MusicSource[];

    for (const source of candidates) {
      if (source.canImportUrl?.(url) && source.importFromUrl) {
        return source.importFromUrl(url);
      }
    }

    return undefined;
  }

  async getStreamUrl(track: Track, preference: AudioQualityPreference = "auto"): Promise<StreamResult> {
    if (track.fileUrl?.startsWith("file://")) {
      return { url: track.fileUrl, quality: track.quality ?? "high" };
    }

    if (track.streamUrl?.startsWith("http")) {
      return { url: track.streamUrl, quality: track.quality ?? "unknown" };
    }

    const source = this.sources.get(track.provider);
    if (!source) {
      throw new SourceUnavailableError("This source is currently unavailable.");
    }

    const localId = extractScopedLocalId(track);
    if (!localId || !source.getStreams) {
      throw new StreamResolveError("This track cannot be resolved for playback.");
    }

    const streams = await source.getStreams(localId);
    const selected = selectPreferredStream(streams, preference);
    if (!selected) {
      throw new StreamResolveError("No usable streams are available for this track.");
    }

    return selected;
  }

  async getLyrics(track: Track) {
    const source = this.sources.get(track.provider);
    if (!source?.getLyrics) {
      return [{ text: "Lyrics are not available for this source yet." }];
    }
    return source.getLyrics(track);
  }

  async getRelated(track: Track) {
    const source = this.sources.get(track.provider);
    if (!source?.getRelated) {
      return [];
    }
    return source.getRelated(track);
  }
}

export const sourceRegistry = new SourceRegistry();

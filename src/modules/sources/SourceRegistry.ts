import { CachedMusicSource } from "@/modules/sources/CachedMusicSource";
import { ExperimentalJioSaavnSource } from "@/modules/sources/ExperimentalJioSaavnSource";
import { ExperimentalSpotifySource } from "@/modules/sources/ExperimentalSpotifySource";
import { useFallbackMatchStore } from "@/modules/sources/fallbackMatchStore";
import { ExperimentalYouTubeSource } from "@/modules/sources/ExperimentalYouTubeSource";
import { ExperimentalYouTubeMusicSource } from "@/modules/sources/ExperimentalYouTubeMusicSource";
import { LocalFilesMusicSource } from "@/modules/sources/LocalFilesMusicSource";
import type { MusicSource } from "@/modules/sources/MusicSource";
import { MockMusicSource } from "@/modules/sources/MockMusicSource";
import { PlaceholderCatalogSource } from "@/modules/sources/PlaceholderCatalogSource";
import {
  buildCanonicalTrackKey,
  buildTrackSearchQuery,
  extractScopedLocalId,
  isProbablyUrl,
  isStreamExpired,
  rankTrackCandidates,
  selectPreferredStream,
} from "@/modules/sources/sourceUtils";
import { logger } from "@/services/logger";
import type { AudioQualityPreference, MusicProvider, ProviderStatus } from "@/types/source";
import type { ImportResult } from "@/modules/sources/sourceModels";
import type { HomeSection } from "@/types/home";
import type { StreamResult, Track } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

type ProviderHealth = {
  provider: MusicProvider;
  status: ProviderStatus;
  error?: string;
};

export class SourceRegistry {
  private sources = new Map<MusicProvider, MusicSource>();
  private enabled = new Set<MusicProvider>();
  private playbackFallbackOrder: MusicProvider[] = ["youtube_music_experimental", "youtube_experimental"];

  constructor() {
    [
      new MockMusicSource(),
      new LocalFilesMusicSource(),
      new ExperimentalSpotifySource(),
      new ExperimentalYouTubeSource(),
      new ExperimentalYouTubeMusicSource(),
      new PlaceholderCatalogSource({ id: "soundcloud_experimental", name: "SoundCloud Experimental" }),
      new PlaceholderCatalogSource({ id: "deezer_experimental", name: "Deezer Experimental" }),
      new PlaceholderCatalogSource({ id: "tidal_experimental", name: "Tidal Experimental" }),
      new PlaceholderCatalogSource({ id: "amazon_music_experimental", name: "Amazon Music Experimental" }),
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

    if (track.streamUrl?.startsWith("http") && !isStreamExpired({ expiresAt: track.streamExpiresAt })) {
      return {
        url: track.streamUrl,
        quality: track.quality ?? "unknown",
        headers: track.streamHeaders,
        format: track.streamFormat,
        mimeType: track.streamMimeType,
        expiresAt: track.streamExpiresAt,
      };
    }

    const source = this.sources.get(track.provider);
    const fallbackProviders = this.getPlaybackFallbackProviders(track.provider);
    const canonicalKey = buildCanonicalTrackKey(track);
    let lastError: unknown;

    if (source?.getStreams) {
      try {
        const resolved = await this.resolveTrackStream(track, preference, source);
        if (resolved) {
          return resolved;
        }
      } catch (error) {
        lastError = error;
        logger.warn("Primary provider stream resolution failed", track.provider, error);
      }
    }

    for (const provider of fallbackProviders) {
      try {
        const resolved = await this.resolveFallbackStream(track, provider, preference, canonicalKey);
        if (resolved) {
          logger.info("Resolved playback through fallback provider", {
            requestedProvider: track.provider,
            fallbackProvider: provider,
            title: track.title,
          });
          return resolved;
        }
      } catch (error) {
        lastError = error;
        logger.warn("Fallback provider stream resolution failed", provider, error);
      }
    }

    if (lastError instanceof Error) {
      throw lastError;
    }

    throw new StreamResolveError("This track cannot be resolved for playback.");
  }

  async getLyrics(track: Track) {
    const source = this.sources.get(track.provider);
    if (!source?.getLyrics) {
      return [{ text: "Lyrics are not available for this source." }];
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

  async getHomeSections(preferredProvider?: MusicProvider): Promise<HomeSection[]> {
    const orderedProviders = preferredProvider
      ? [preferredProvider, ...[...this.enabled].filter((provider) => provider !== preferredProvider)]
      : [...this.enabled];
    let lastError: unknown;

    for (const provider of orderedProviders) {
      const source = this.sources.get(provider);
      if (!source?.getHomeSections) {
        continue;
      }

      try {
        const sections = await source.getHomeSections();
        if (sections.length) {
          return sections;
        }
      } catch (error) {
        lastError = error;
        logger.warn("Provider home load failed", provider, error);
      }
    }

    if (lastError) {
      throw lastError;
    }

    return [];
  }

  private getPlaybackFallbackProviders(origin: MusicProvider) {
    return this.playbackFallbackOrder.filter(
      (provider) => provider !== origin && this.enabled.has(provider) && this.sources.has(provider),
    );
  }

  private async resolveTrackStream(
    track: Track,
    preference: AudioQualityPreference,
    source: MusicSource,
  ): Promise<StreamResult | undefined> {
    const localId = extractScopedLocalId(track);
    if (!localId || !source.getStreams) {
      return undefined;
    }

    const streams = await source.getStreams(localId);
    const selected = selectPreferredStream(streams, preference);
    if (!selected) {
      return undefined;
    }

    return {
      ...selected,
      resolvedTrack: track,
    };
  }

  private async resolveFallbackStream(
    track: Track,
    provider: MusicProvider,
    preference: AudioQualityPreference,
    canonicalKey: string,
  ): Promise<StreamResult | undefined> {
    const source = this.sources.get(provider);
    if (!source?.search || !source.getStreams) {
      return undefined;
    }

    const cached = this.resolveCachedFallbackTrack(track, provider, canonicalKey);
    if (cached) {
      try {
        const stream = await this.resolveTrackStream(cached, preference, source);
        if (stream) {
          return {
            ...stream,
            resolvedTrack: cached,
          };
        }
      } catch (error) {
        logger.warn("Cached fallback stream is no longer playable", provider, cached.localId, error);
      }
    }

    const query = buildTrackSearchQuery(track);
    if (!query) {
      return undefined;
    }

    const candidates = await source.search(query);
    const matches = rankTrackCandidates(track, candidates).slice(0, 4);
    if (!matches.length) {
      return undefined;
    }
    let lastError: unknown;

    for (const match of matches) {
      const matchKind = track.isrc && match.isrc && track.isrc === match.isrc ? "isrc" : "metadata_search";
      const matchedTrack: Track = {
        ...match,
        playbackProvider: provider,
        fallbackFromProvider: track.provider,
        playbackMatchKind: matchKind,
      };

      try {
        const stream = await this.resolveTrackStream(matchedTrack, preference, source);
        if (!stream) {
          continue;
        }

        this.cacheFallbackMatch(canonicalKey, matchedTrack, matchKind);
        return {
          ...stream,
          resolvedTrack: matchedTrack,
        };
      } catch (error) {
        lastError = error;
        logger.warn("Fallback candidate was not playable", provider, matchedTrack.localId, error);
      }
    }

    if (lastError instanceof Error) {
      throw lastError;
    }
    return undefined;
  }

  private resolveCachedFallbackTrack(track: Track, provider: MusicProvider, canonicalKey: string): Track | undefined {
    const cached = useFallbackMatchStore.getState().getMatch(canonicalKey);
    if (!cached || cached.targetProvider !== provider || !cached.localId) {
      return undefined;
    }

    return {
      ...track,
      id: `${provider}::${cached.localId}`,
      provider,
      localId: cached.localId,
      providerTrackId: cached.localId,
      sourceUrl: cached.sourceUrl ?? track.sourceUrl,
      title: cached.title || track.title,
      artist: cached.artist || track.artist,
      artwork: cached.artwork ?? track.artwork,
      duration: cached.duration ?? track.duration,
      playbackProvider: provider,
      fallbackFromProvider: track.provider,
      playbackMatchKind: "cached_fallback",
    };
  }

  private cacheFallbackMatch(canonicalKey: string, track: Track, matchKind: "isrc" | "metadata_search") {
    const localId = extractScopedLocalId(track);
    if (!localId) {
      return;
    }

    useFallbackMatchStore.getState().saveMatch(canonicalKey, {
      targetProvider: track.provider,
      localId,
      sourceUrl: track.sourceUrl,
      title: track.title,
      artist: track.artist,
      artwork: track.artwork,
      duration: track.duration,
      matchedAt: Date.now(),
      matchKind,
    });
  }
}

export const sourceRegistry = new SourceRegistry();

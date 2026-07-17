import type { MusicSource } from "@/modules/sources/MusicSource";
import { fetchLyricsFromLrclib } from "@/modules/sources/lyrics/lrclib";
import { fetchMusicBrainzGenres } from "@/modules/sources/metadata/musicBrainz";
import { spotifyClient } from "@/modules/sources/spotify/client";
import {
  parseSpotifyAlbumImport,
  parseSpotifyPlaylistImport,
  parseSpotifySearchTracks,
  parseSpotifyTrack,
  parseSpotifyUrlIntent,
} from "@/modules/sources/spotify/parser";
import type { ImportResult } from "@/modules/sources/sourceModels";
import type { Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

export class ExperimentalSpotifySource implements MusicSource {
  id = "spotify_experimental" as const;
  name = "Spotify Experimental";
  status = "enabled" as const;

  canHandleUrl(url: string) {
    const intent = parseSpotifyUrlIntent(url);
    return intent?.type === "track";
  }

  canImportUrl(url: string) {
    const intent = parseSpotifyUrlIntent(url);
    return intent?.type === "album" || intent?.type === "playlist";
  }

  async search(query: string): Promise<Track[]> {
    const trimmed = query.trim();
    if (!trimmed) {
      return [];
    }

    const intent = parseSpotifyUrlIntent(trimmed);
    if (intent?.type === "track") {
      return [await this.getTrackDetails(intent.id)];
    }

    const payload = await spotifyClient.searchTracks(trimmed, 20);
    return parseSpotifySearchTracks(payload);
  }

  async resolveTrackFromUrl(url: string): Promise<Track> {
    const intent = parseSpotifyUrlIntent(url);
    if (!intent || intent.type !== "track") {
      throw new SourceUnavailableError("This Spotify track link could not be parsed.");
    }

    return this.getTrackDetails(intent.id);
  }

  async importFromUrl(url: string): Promise<ImportResult> {
    const intent = parseSpotifyUrlIntent(url);
    if (!intent) {
      throw new SourceUnavailableError("This Spotify link could not be parsed.");
    }

    if (intent.type === "album") {
      const payload = await spotifyClient.getAlbum(intent.id);
      return parseSpotifyAlbumImport(payload);
    }

    if (intent.type === "playlist") {
      const payload = await spotifyClient.getPlaylist(intent.id);
      return parseSpotifyPlaylistImport(payload);
    }

    throw new SourceUnavailableError("Spotify URL import currently supports albums and playlists.");
  }

  async getTrackDetails(localId: string): Promise<Track> {
    const [payload, identifiers] = await Promise.all([
      spotifyClient.getTrack(localId),
      spotifyClient.getTrackIdentifiers(localId),
    ]);

    const genres = await fetchMusicBrainzGenres(identifiers.isrc);
    return parseSpotifyTrack(payload, { isrc: identifiers.isrc, upc: identifiers.upc, genres });
  }

  async getLyrics(track: Track) {
    return fetchLyricsFromLrclib(track);
  }
}

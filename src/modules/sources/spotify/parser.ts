import type { ImportResult } from "@/modules/sources/sourceModels";
import { buildScopedTrackId } from "@/modules/sources/sourceUtils";
import {
  cleanSpotifyReleaseDate,
  extractArtists,
  extractCoverArt,
  extractSpotifyId,
  formatSpotifyDuration,
  getArray,
  getBoolean,
  getNumber,
  getObject,
  getString,
} from "@/modules/sources/spotify/helpers";
import type { Track } from "@/types/track";

export type SpotifyUrlIntent =
  | { type: "track"; id: string }
  | { type: "album"; id: string }
  | { type: "playlist"; id: string }
  | { type: "artist"; id: string };

export const parseSpotifyUrlIntent = (input: string): SpotifyUrlIntent | undefined => {
  const trimmed = input.trim();
  if (!trimmed) {
    return undefined;
  }

  if (trimmed.startsWith("spotify:")) {
    const parts = trimmed.split(":");
    if (parts.length === 3) {
      const type = parts[1];
      const id = parts[2];
      if (type === "track" || type === "album" || type === "playlist" || type === "artist") {
        return { type, id };
      }
    }
    return undefined;
  }

  let url: URL;
  try {
    url = new URL(trimmed);
  } catch {
    return undefined;
  }

  if (!["open.spotify.com", "play.spotify.com"].includes(url.hostname)) {
    return undefined;
  }

  const parts = url.pathname.split("/").filter(Boolean);
  const normalized = parts[0]?.startsWith("intl-") ? parts.slice(1) : parts;
  const path = normalized[0] === "embed" ? normalized.slice(1) : normalized;
  const type = path[0];
  const id = path[1];

  if (!id) {
    return undefined;
  }

  if (type === "track" || type === "album" || type === "playlist" || type === "artist") {
    return { type, id };
  }

  return undefined;
};

const buildArtists = (artists: { id: string; name: string }[]) => ({
  primary: artists[0]?.name ?? "Unknown artist",
  list: artists.map((artist) => artist.name),
  firstArtistId: artists[0]?.id,
});

export const parseSpotifySearchTracks = (payload: Record<string, unknown>): Track[] => {
  const items = getArray(getObject(getObject(getObject(payload.data).searchV2).tracksV2).items);

  return items
    .map((entry) => {
      const track = getObject(getObject(getObject(entry).item).data);
      if (!Object.keys(track).length) {
        return undefined;
      }

      const uri = getString(track.uri);
      const id = extractSpotifyId(getString(track.id) || uri);
      const album = getObject(track.albumOfTrack);
      const artists = extractArtists(track.artists);
      const artistMeta = buildArtists(artists);
      const title = getString(track.name);
      if (!id || !title) {
        return undefined;
      }

      return {
        id: buildScopedTrackId("spotify_experimental", id),
        provider: "spotify_experimental",
        localId: id,
        providerTrackId: id,
        providerAlbumId: extractSpotifyId(getString(album.uri) || getString(album.id)),
        providerArtistId: artistMeta.firstArtistId,
        title,
        artist: artistMeta.primary,
        artists: artistMeta.list,
        album: getString(album.name) || undefined,
        artwork: extractCoverArt(album.coverArt),
        duration: formatSpotifyDuration(
          getNumber(getObject(track.duration).totalMilliseconds) || getNumber(getObject(track.trackDuration).totalMilliseconds),
        ),
        sourceUrl: `https://open.spotify.com/track/${id}`,
        isExplicit: getString(getObject(track.contentRating).label) === "EXPLICIT",
      } satisfies Track;
    })
    .filter(Boolean) as Track[];
};

export const parseSpotifyTrack = (payload: Record<string, unknown>, extras?: { isrc?: string; upc?: string; genres?: string[] }) => {
  const track = getObject(getObject(payload.data).trackUnion);
  const uri = getString(track.uri);
  const id = extractSpotifyId(getString(track.id) || uri);
  const album = getObject(track.albumOfTrack);
  const artists = extractArtists(track.artists);
  const artistMeta = buildArtists(artists);

  return {
    id: buildScopedTrackId("spotify_experimental", id),
    provider: "spotify_experimental",
    localId: id,
    providerTrackId: id,
    providerAlbumId: extractSpotifyId(getString(album.id) || getString(album.uri)),
    providerArtistId: artistMeta.firstArtistId,
    title: getString(track.name),
    artist: artistMeta.primary,
    artists: artistMeta.list,
    album: getString(album.name) || undefined,
    artwork: extractCoverArt(album.coverArt),
    duration: formatSpotifyDuration(
      getNumber(getObject(track.duration).totalMilliseconds) || getNumber(getObject(track.trackDuration).totalMilliseconds),
    ),
    sourceUrl: `https://open.spotify.com/track/${id}`,
    isExplicit: getString(getObject(track.contentRating).label) === "EXPLICIT",
    isrc: extras?.isrc,
    upc: extras?.upc,
    genres: extras?.genres,
  } satisfies Track;
};

const mapAlbumTrack = (trackNode: Record<string, unknown>, albumNode: Record<string, unknown>, upc?: string): Track | undefined => {
  const track = getObject(getObject(trackNode.track).track);
  const mergedTrack = Object.keys(track).length ? track : trackNode;
  const uri = getString(mergedTrack.uri);
  const id = extractSpotifyId(getString(mergedTrack.id) || uri);
  const artists = extractArtists(mergedTrack.artists);
  const artistMeta = buildArtists(artists);
  const title = getString(mergedTrack.name);
  if (!id || !title) {
    return undefined;
  }

  return {
    id: buildScopedTrackId("spotify_experimental", id),
    provider: "spotify_experimental",
    localId: id,
    providerTrackId: id,
    providerAlbumId: extractSpotifyId(getString(albumNode.id) || getString(albumNode.uri)),
    providerArtistId: artistMeta.firstArtistId,
    title,
    artist: artistMeta.primary,
    artists: artistMeta.list,
    album: getString(albumNode.name) || undefined,
    artwork: extractCoverArt(albumNode.coverArt),
    duration: formatSpotifyDuration(
      getNumber(getObject(mergedTrack.duration).totalMilliseconds) ||
        getNumber(getObject(mergedTrack.trackDuration).totalMilliseconds),
    ),
    sourceUrl: `https://open.spotify.com/track/${id}`,
    isExplicit: getString(getObject(mergedTrack.contentRating).label) === "EXPLICIT",
    upc,
  };
};

export const parseSpotifyAlbumImport = (payload: Record<string, unknown>, upc?: string): ImportResult => {
  const album = getObject(getObject(payload.data).albumUnion);
  const items = getArray(getObject(album.tracksV2).items);
  const albumId = extractSpotifyId(getString(album.id) || getString(album.uri));

  return {
    collection: {
      id: `spotify_experimental::album::${albumId}`,
      title: getString(album.name) || "Spotify Album",
      sourceUrl: `https://open.spotify.com/album/${albumId}`,
      artwork: extractCoverArt(album.coverArt),
    },
    tracks: items
      .map((item) => mapAlbumTrack(getObject(item), album, upc))
      .filter(Boolean) as Track[],
  };
};

export const parseSpotifyPlaylistImport = (payload: Record<string, unknown>): ImportResult => {
  const playlist = getObject(getObject(payload.data).playlistV2);
  const content = getObject(playlist.content);
  const items = getArray(content.items);
  const playlistId = extractSpotifyId(getString(playlist.uri) || getString(playlist.id));
  const cover = extractCoverArt(playlist.images) || extractCoverArt(playlist.coverArt);

  return {
    collection: {
      id: `spotify_experimental::playlist::${playlistId}`,
      title: getString(playlist.name) || "Spotify Playlist",
      sourceUrl: `https://open.spotify.com/playlist/${playlistId}`,
      artwork: cover,
    },
    tracks: items
      .map((item) => {
        const trackWrapper = getObject(item);
        const track = getObject(trackWrapper.itemV2);
        const data = getObject(track.data);
        return mapAlbumTrack(data, getObject(data.albumOfTrack));
      })
      .filter(Boolean) as Track[],
  };
};

export const parseSpotifyAlbumDetails = (payload: Record<string, unknown>) => {
  const album = getObject(getObject(payload.data).albumUnion);
  return {
    id: extractSpotifyId(getString(album.id) || getString(album.uri)),
    title: getString(album.name),
    artists: extractArtists(album.artists).map((artist) => artist.name),
    artwork: extractCoverArt(album.coverArt),
    releaseDate: cleanSpotifyReleaseDate(album.date),
  };
};

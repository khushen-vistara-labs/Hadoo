import { logger } from "@/services/logger";
import { decodeBase64ToString } from "@/modules/sources/spotify/encoding";
import { getArray, getObject, getString } from "@/modules/sources/spotify/helpers";
import { generateSpotifyTotp, SPOTIFY_TOTP_VERSION } from "@/modules/sources/spotify/totp";
import { SourceUnavailableError } from "@/utils/errors";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36";
const TOKEN_URL = "https://open.spotify.com/api/token";
const SESSION_URL = "https://open.spotify.com";
const CLIENT_TOKEN_URL = "https://clienttoken.spotify.com/v1/clienttoken";
const PATHFINDER_URL = "https://api-partner.spotify.com/pathfinder/v2/query";
const SPCLIENT_BASE = "https://spclient.wg.spotify.com/metadata/4";

const SEARCH_HASH = "fcad5a3e0d5af727fb76966f06971c19cfa2275e6ff7671196753e008611873c";
const TRACK_HASH = "612585ae06ba435ad26369870deaae23b5c8800a256cd8a57e08eddc25a37294";
const ALBUM_HASH = "b9bfabef66ed756e5e13f68a942deb60bd4125ec1f1be8cc42769dc0259b4b10";
const PLAYLIST_HASH = "bb67e0af06e8d6f52b531f97468ee4acd44cd0f82b988e15c2ea47b1148efc77";

type SpotifyTokens = {
  accessToken: string;
  accessTokenExpiresAt: number;
  clientId: string;
  clientToken: string;
  clientVersion: string;
  deviceId: string;
  cookies: string;
};

let cachedTokens: SpotifyTokens | undefined;

const randomDeviceId = () => {
  const parts = Array.from({ length: 32 }, () => Math.floor(Math.random() * 16).toString(16));
  return parts.join("");
};

const extractCookies = (response: Response) => {
  const setCookie = response.headers.get("set-cookie") ?? response.headers.get("Set-Cookie") ?? "";
  if (!setCookie) {
    return "";
  }

  return setCookie
    .split(/,(?=[^;]+=[^;]+)/)
    .map((value) => value.split(";")[0]?.trim())
    .filter(Boolean)
    .join("; ");
};

const parseClientVersion = (html: string) => {
  const match = html.match(/<script id="appServerConfig" type="text\/plain">([^<]+)<\/script>/i);
  if (!match?.[1]) {
    return "";
  }

  try {
    const decoded = decodeBase64ToString(match[1]);
    const parsed = JSON.parse(decoded) as { clientVersion?: string };
    return parsed.clientVersion ?? "";
  } catch {
    return "";
  }
};

const fetchAccessToken = async (offsetMs = 0) => {
  const totp = generateSpotifyTotp(Date.now() + offsetMs);
  const params = new URLSearchParams({
    reason: "init",
    productType: "web-player",
    totp,
    totpVer: String(SPOTIFY_TOTP_VERSION),
    totpServer: totp,
  });

  const response = await fetch(`${TOKEN_URL}?${params.toString()}`, {
    headers: {
      "user-agent": USER_AGENT,
      "content-type": "application/json;charset=UTF-8",
    },
  });

  if (!response.ok) {
    throw new SourceUnavailableError(`Spotify token request failed with ${response.status}`);
  }

  return {
    payload: (await response.json()) as {
      accessToken?: string;
      accessTokenExpirationTimestampMs?: number;
      clientId?: string;
    },
    cookies: extractCookies(response),
  };
};

const fetchSessionInfo = async (cookieHeader?: string) => {
  const response = await fetch(SESSION_URL, {
    headers: {
      "user-agent": USER_AGENT,
      ...(cookieHeader ? { cookie: cookieHeader } : {}),
    },
  });

  if (!response.ok) {
    throw new SourceUnavailableError(`Spotify session request failed with ${response.status}`);
  }

  const html = await response.text();
  const clientVersion = parseClientVersion(html);
  const cookies = extractCookies(response);
  const deviceId = cookies.match(/sp_t=([^;]+)/)?.[1] ?? randomDeviceId();

  return { clientVersion, cookies, deviceId };
};

const fetchClientToken = async (tokens: Pick<SpotifyTokens, "clientId" | "clientVersion" | "deviceId">) => {
  const response = await fetch(CLIENT_TOKEN_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      accept: "application/json",
      "user-agent": USER_AGENT,
    },
    body: JSON.stringify({
      client_data: {
        client_version: tokens.clientVersion,
        client_id: tokens.clientId,
        js_sdk_data: {
          device_brand: "unknown",
          device_model: "unknown",
          os: "windows",
          os_version: "NT 10.0",
          device_id: tokens.deviceId,
          device_type: "computer",
        },
      },
    }),
  });

  if (!response.ok) {
    throw new SourceUnavailableError(`Spotify client token request failed with ${response.status}`);
  }

  const payload = (await response.json()) as {
    response_type?: string;
    granted_token?: { token?: string };
  };

  const token = payload.granted_token?.token;
  if (payload.response_type !== "RESPONSE_GRANTED_TOKEN_RESPONSE" || !token) {
    throw new SourceUnavailableError("Spotify client token response was invalid.");
  }

  return token;
};

const getTokens = async () => {
  if (cachedTokens && cachedTokens.accessTokenExpiresAt - Date.now() > 30_000) {
    return cachedTokens;
  }

  const session = await fetchSessionInfo();
  let accessData;
  try {
    accessData = await fetchAccessToken(0);
  } catch {
    accessData = await fetchAccessToken(-30_000);
  }

  const accessToken = accessData.payload.accessToken ?? "";
  const clientId = accessData.payload.clientId ?? "";
  const accessTokenExpiresAt = accessData.payload.accessTokenExpirationTimestampMs ?? Date.now() + 50 * 60_000;
  const clientVersion = session.clientVersion || "hadoo-spotify";
  const deviceId = session.deviceId;
  const cookies = [session.cookies, accessData.cookies].filter(Boolean).join("; ");

  if (!accessToken || !clientId) {
    throw new SourceUnavailableError("Spotify access token response was missing required fields.");
  }

  const clientToken = await fetchClientToken({ clientId, clientVersion, deviceId });
  cachedTokens = { accessToken, accessTokenExpiresAt, clientId, clientToken, clientVersion, deviceId, cookies };
  return cachedTokens;
};

const query = async (payload: Record<string, unknown>) => {
  const tokens = await getTokens();
  const response = await fetch(PATHFINDER_URL, {
    method: "POST",
    headers: {
      authorization: `Bearer ${tokens.accessToken}`,
      "client-token": tokens.clientToken,
      "spotify-app-version": tokens.clientVersion,
      "content-type": "application/json",
      "user-agent": USER_AGENT,
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    cachedTokens = undefined;
    throw new SourceUnavailableError(`Spotify query failed with ${response.status}`);
  }

  return (await response.json()) as Record<string, unknown>;
};

const requestAnonymousSpotifyToken = async () => {
  const { payload } = await fetchAccessToken(0);
  if (!payload.accessToken) {
    throw new SourceUnavailableError("Spotify anonymous metadata token was missing.");
  }
  return payload.accessToken;
};

const toHex = (spotifyId: string) => {
  const alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  let value = 0n;
  for (const char of spotifyId) {
    const index = alphabet.indexOf(char);
    if (index < 0) {
      continue;
    }
    value = value * 62n + BigInt(index);
  }
  return value.toString(16).padStart(32, "0");
};

const getSpclientJson = async (type: "track" | "album", spotifyId: string) => {
  const token = await requestAnonymousSpotifyToken();
  const gid = toHex(spotifyId);
  const response = await fetch(`${SPCLIENT_BASE}/${type}/${gid}?market=from_token`, {
    headers: {
      authorization: `Bearer ${token}`,
      "user-agent": USER_AGENT,
    },
  });

  if (!response.ok) {
    throw new SourceUnavailableError(`Spotify ${type} metadata request failed with ${response.status}`);
  }

  return (await response.json()) as Record<string, unknown>;
};

const extractExternalId = (payload: Record<string, unknown>, targetType: string) => {
  const externalIds = getArray(getObject(payload).external_id);
  for (const item of externalIds) {
    const object = getObject(item);
    if (getString(object.type).toLowerCase() === targetType.toLowerCase()) {
      return getString(object.id) || getString(object.value);
    }
  }
  return "";
};

export const spotifyClient = {
  searchTracks(queryText: string, limit = 20) {
    return query({
      variables: {
        searchTerm: queryText,
        offset: 0,
        limit,
        numberOfTopResults: 5,
        includeAudiobooks: true,
        includeArtistHasConcertsField: false,
        includePreReleases: true,
        includeAuthors: false,
      },
      operationName: "searchDesktop",
      extensions: {
        persistedQuery: {
          version: 1,
          sha256Hash: SEARCH_HASH,
        },
      },
    });
  },

  getTrack(trackId: string) {
    return query({
      variables: {
        uri: `spotify:track:${trackId}`,
      },
      operationName: "getTrack",
      extensions: {
        persistedQuery: {
          version: 1,
          sha256Hash: TRACK_HASH,
        },
      },
    });
  },

  getAlbum(albumId: string, offset = 0, limit = 100) {
    return query({
      variables: {
        uri: `spotify:album:${albumId}`,
        locale: "",
        offset,
        limit,
      },
      operationName: "getAlbum",
      extensions: {
        persistedQuery: {
          version: 1,
          sha256Hash: ALBUM_HASH,
        },
      },
    });
  },

  getPlaylist(playlistId: string, offset = 0, limit = 100) {
    return query({
      variables: {
        uri: `spotify:playlist:${playlistId}`,
        offset,
        limit,
        enableWatchFeedEntrypoint: false,
      },
      operationName: "fetchPlaylist",
      extensions: {
        persistedQuery: {
          version: 1,
          sha256Hash: PLAYLIST_HASH,
        },
      },
    });
  },

  async getTrackIdentifiers(trackId: string) {
    try {
      const trackPayload = await getSpclientJson("track", trackId);
      const albumGid = getString(getObject(getObject(trackPayload.album).gid));
      const albumId = albumGid ? BigInt(`0x${albumGid}`).toString(10) : "";
      void albumId;

      let upc = "";
      try {
        const albumUri = getString(getObject(trackPayload.album).uri);
        const extractedAlbumId = albumUri ? albumUri.split(":").at(-1) ?? "" : "";
        if (extractedAlbumId) {
          const albumPayload = await getSpclientJson("album", extractedAlbumId);
          upc = extractExternalId(albumPayload, "upc");
        }
      } catch (error) {
        logger.warn("Spotify album identifier lookup failed", error);
      }

      return {
        isrc: extractExternalId(trackPayload, "isrc"),
        upc,
      };
    } catch (error) {
      logger.warn("Spotify track identifier lookup failed", error);
      return { isrc: "", upc: "" };
    }
  },

  async getPreviewUrl(trackId: string) {
    const response = await fetch(`https://open.spotify.com/embed/track/${trackId}`, {
      headers: { "user-agent": USER_AGENT },
    });

    if (!response.ok) {
      return undefined;
    }

    const html = await response.text();
    return html.match(/https:\/\/p\.scdn\.co\/mp3-preview\/[A-Za-z0-9]+/)?.[0];
  },
};

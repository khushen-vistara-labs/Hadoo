const normalizeDeezerTrackUrl = (url: string) => {
  try {
    const parsed = new URL(url);
    if (!parsed.hostname.includes("deezer.com")) {
      return undefined;
    }
    const match = parsed.pathname.match(/\/track\/(\d+)/);
    return match?.[1];
  } catch {
    return undefined;
  }
};

export const fetchDeezerTrackByIsrc = async (isrc: string) => {
  const response = await fetch(`https://api.deezer.com/track/isrc:${encodeURIComponent(isrc)}`);
  if (!response.ok) {
    throw new Error(`Deezer ISRC lookup failed with ${response.status}`);
  }
  return (await response.json()) as { link?: string; id?: number; isrc?: string };
};

export const fetchDeezerIsrcFromUrl = async (url: string) => {
  const trackId = normalizeDeezerTrackUrl(url);
  if (!trackId) {
    return "";
  }

  const response = await fetch(`https://api.deezer.com/track/${trackId}`);
  if (!response.ok) {
    return "";
  }

  const payload = (await response.json()) as { isrc?: string };
  return payload.isrc?.trim() ?? "";
};

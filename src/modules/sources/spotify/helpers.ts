export const getString = (value: unknown) => (typeof value === "string" ? value : "");
export const getNumber = (value: unknown) => (typeof value === "number" ? value : 0);
export const getBoolean = (value: unknown) => (typeof value === "boolean" ? value : false);
export const getObject = (value: unknown): Record<string, unknown> =>
  value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
export const getArray = (value: unknown) => (Array.isArray(value) ? value : []);

export const extractSpotifyId = (value: string) => {
  const trimmed = value.trim();
  if (!trimmed) {
    return "";
  }

  const parts = trimmed.split(":");
  if (parts.length >= 3 && parts[0] === "spotify") {
    return parts.at(-1) ?? "";
  }

  const slashParts = trimmed.split("/");
  const last = slashParts.at(-1) ?? trimmed;
  return last.split("?")[0] ?? "";
};

export const extractArtists = (artistsNode: unknown) => {
  const items = getArray(getObject(artistsNode).items);
  const artists = items
    .map((item) => {
      const profile = getObject(getObject(item).profile);
      const uri = getString(getObject(item).uri);
      return {
        id: extractSpotifyId(uri),
        name: getString(profile.name),
      };
    })
    .filter((item) => item.name);

  if (artists.length) {
    return artists;
  }

  const firstArtist = getArray(getObject(getObject(artistsNode).firstArtist).items);
  const otherArtists = getArray(getObject(getObject(artistsNode).otherArtists).items);
  return [...firstArtist, ...otherArtists]
    .map((item) => {
      const object = getObject(item);
      const profile = getObject(object.profile);
      const uri = getString(object.uri);
      return {
        id: extractSpotifyId(uri),
        name: getString(profile.name),
      };
    })
    .filter((item) => item.name);
};

export const extractCoverArt = (coverNode: unknown) => {
  const cover = getObject(coverNode);
  const sources =
    getArray(cover.sources).length > 0
      ? getArray(cover.sources)
      : getArray(getObject(getObject(getObject(cover.squareCoverImage).image).data).sources);

  const urls = sources
    .map((source) => getString(getObject(source).url))
    .filter(Boolean);

  if (!urls.length) {
    return undefined;
  }

  return urls[urls.length - 1];
};

export const formatSpotifyDuration = (milliseconds: number) => Math.round(milliseconds / 1000);

export const cleanSpotifyReleaseDate = (dateNode: unknown) => {
  const object = getObject(dateNode);
  const isoString = getString(object.isoString);
  if (isoString) {
    return isoString.split("T")[0] ?? isoString;
  }

  const year = getString(object.year);
  const month = getString(object.month);
  const day = getString(object.day);
  if (year && month && day) {
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  }
  return year || undefined;
};

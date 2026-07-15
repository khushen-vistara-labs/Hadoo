const YOUTUBE_HOSTS = new Set([
  "youtube.com",
  "www.youtube.com",
  "m.youtube.com",
  "music.youtube.com",
  "youtu.be",
  "www.youtu.be",
]);

const VIDEO_ID_PATTERN = /^[a-zA-Z0-9_-]{11}$/;

const safeUrl = (value: string) => {
  try {
    return new URL(value.trim());
  } catch {
    return undefined;
  }
};

export const isYouTubeUrl = (value: string) => {
  const url = safeUrl(value);
  return Boolean(url && YOUTUBE_HOSTS.has(url.hostname.toLowerCase()));
};

export const extractYouTubeVideoId = (value: string) => {
  const url = safeUrl(value);
  if (!url || !YOUTUBE_HOSTS.has(url.hostname.toLowerCase())) {
    return undefined;
  }

  if (url.hostname.toLowerCase().includes("youtu.be")) {
    const candidate = url.pathname.replace(/^\/+/, "").split("/")[0];
    return VIDEO_ID_PATTERN.test(candidate) ? candidate : undefined;
  }

  const directId = url.searchParams.get("v");
  if (directId && VIDEO_ID_PATTERN.test(directId)) {
    return directId;
  }

  const pathSegments = url.pathname.split("/").filter(Boolean);
  const embedIndex = pathSegments.findIndex((segment) => segment === "embed" || segment === "shorts");
  if (embedIndex >= 0) {
    const candidate = pathSegments[embedIndex + 1];
    return candidate && VIDEO_ID_PATTERN.test(candidate) ? candidate : undefined;
  }

  return undefined;
};

export const extractYouTubePlaylistId = (value: string) => {
  const url = safeUrl(value);
  if (!url || !YOUTUBE_HOSTS.has(url.hostname.toLowerCase())) {
    return undefined;
  }

  const list = url.searchParams.get("list");
  return list?.trim() || undefined;
};

export const extractYouTubeBrowseId = (value: string) => {
  const url = safeUrl(value);
  if (!url || !YOUTUBE_HOSTS.has(url.hostname.toLowerCase())) {
    return undefined;
  }

  const pathSegments = url.pathname.split("/").filter(Boolean);
  const browseIndex = pathSegments.findIndex((segment) => segment === "browse");
  const candidate = browseIndex >= 0 ? pathSegments[browseIndex + 1] : undefined;

  return candidate?.trim() || undefined;
};

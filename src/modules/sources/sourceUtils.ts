import type { AudioQualityPreference } from "@/types/source";
import type { StreamSource, Track, TrackQuality } from "@/types/track";

const qualityOrder: Record<Exclude<AudioQualityPreference, "auto">, TrackQuality[]> = {
  low: ["low", "medium", "high", "lossless", "unknown"],
  medium: ["medium", "high", "low", "lossless", "unknown"],
  high: ["lossless", "high", "medium", "low", "unknown"],
};

export const buildScopedTrackId = (providerId: Track["provider"], localId: string) => `${providerId}::${localId}`;

export const extractScopedLocalId = (track: Track) => {
  if (track.localId) {
    return track.localId;
  }

  const [providerId, localId] = track.id.split("::");
  if (providerId === track.provider && localId) {
    return localId;
  }

  return track.providerTrackId ?? track.id;
};

export const isProbablyUrl = (value: string) => /^https?:\/\//i.test(value.trim());

export const normalizeTrackText = (value?: string) =>
  (value ?? "")
    .toLowerCase()
    .replace(/\([^)]*\)/g, " ")
    .replace(/\[[^\]]*\]/g, " ")
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();

export const buildTrackSearchQuery = (track: Track) => {
  const artist = track.artists?.[0] ?? track.artist;
  return [track.title, artist].filter(Boolean).join(" ").trim();
};

const scoreTextAffinity = (left?: string, right?: string) => {
  const normalizedLeft = normalizeTrackText(left);
  const normalizedRight = normalizeTrackText(right);

  if (!normalizedLeft || !normalizedRight) {
    return 0;
  }

  if (normalizedLeft === normalizedRight) {
    return 1;
  }

  if (normalizedLeft.includes(normalizedRight) || normalizedRight.includes(normalizedLeft)) {
    return 0.7;
  }

  const leftWords = new Set(normalizedLeft.split(" "));
  const rightWords = normalizedRight.split(" ");
  const overlap = rightWords.filter((word) => leftWords.has(word)).length;
  return overlap / Math.max(leftWords.size, rightWords.length, 1);
};

export const scoreTrackCandidate = (seed: Track, candidate: Track) => {
  const titleScore = scoreTextAffinity(seed.title, candidate.title) * 60;
  const artistScore = scoreTextAffinity(seed.artists?.[0] ?? seed.artist, candidate.artists?.[0] ?? candidate.artist) * 30;
  const albumScore = scoreTextAffinity(seed.album, candidate.album) * 10;

  const durationDelta =
    seed.duration != null && candidate.duration != null ? Math.abs(seed.duration - candidate.duration) : undefined;
  const durationScore =
    durationDelta == null ? 0 : durationDelta <= 3 ? 20 : durationDelta <= 8 ? 12 : durationDelta <= 15 ? 6 : 0;

  return titleScore + artistScore + albumScore + durationScore;
};

export const findBestTrackCandidate = (seed: Track, candidates: Track[], minimumScore = 45) => {
  let best: Track | undefined;
  let bestScore = minimumScore;

  candidates.forEach((candidate) => {
    const score = scoreTrackCandidate(seed, candidate);
    if (score > bestScore) {
      best = candidate;
      bestScore = score;
    }
  });

  return best;
};

export const isStreamExpired = (stream: Pick<StreamSource, "expiresAt">, minimumRemainingMs = 60_000) => {
  if (!stream.expiresAt) {
    return false;
  }

  return stream.expiresAt - Date.now() <= minimumRemainingMs;
};

export const isUsableStream = (stream: StreamSource) => /^https?:\/\//i.test(stream.url) && !isStreamExpired(stream);

export const normalizeAudioPreference = (value: AudioQualityPreference): Exclude<AudioQualityPreference, "auto"> =>
  value === "auto" ? "high" : value;

export const selectPreferredStream = (
  streams: StreamSource[],
  preference: AudioQualityPreference,
): StreamSource | undefined => {
  const usable = streams.filter(isUsableStream);
  if (!usable.length) {
    return undefined;
  }

  const orderedQualities = qualityOrder[normalizeAudioPreference(preference)];

  for (const quality of orderedQualities) {
    const match = usable.find((stream) => stream.quality === quality);
    if (match) {
      return match;
    }
  }

  return usable[0];
};

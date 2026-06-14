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

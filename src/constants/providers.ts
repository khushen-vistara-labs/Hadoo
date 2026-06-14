import type { MusicProvider } from "@/types/source";

export const providerLabels: Record<MusicProvider, string> = {
  mock: "Mock",
  local: "Local",
  youtube_music_experimental: "YouTube",
  jiosaavn_experimental: "JioSaavn Experimental",
  cached: "Cached",
};

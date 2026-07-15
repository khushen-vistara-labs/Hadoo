import type { MusicProvider } from "@/types/source";

export const providerLabels: Record<MusicProvider, string> = {
  mock: "Mock",
  local: "Local",
  youtube_experimental: "YouTube",
  youtube_music_experimental: "YouTube Music",
  spotify_experimental: "Spotify",
  amazon_music_experimental: "Amazon Music",
  tidal_experimental: "Tidal",
  deezer_experimental: "Deezer",
  soundcloud_experimental: "SoundCloud",
  jiosaavn_experimental: "JioSaavn Experimental",
  cached: "Cached",
};

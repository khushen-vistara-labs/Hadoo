export type MusicProvider =
  | "mock"
  | "local"
  | "youtube_experimental"
  | "youtube_music_experimental"
  | "spotify_experimental"
  | "amazon_music_experimental"
  | "tidal_experimental"
  | "deezer_experimental"
  | "soundcloud_experimental"
  | "jiosaavn_experimental"
  | "cached";

export type AudioQualityPreference = "auto" | "low" | "medium" | "high";

export type ProviderStatus =
  | "enabled"
  | "disabled"
  | "broken"
  | "rate_limited"
  | "needs_update"
  | "not_implemented";

export type ProviderFilter = MusicProvider | "all";

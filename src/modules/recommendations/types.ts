import type { HomeSection } from "@/types/home";
import type { MusicProvider } from "@/types/source";
import type { Track } from "@/types/track";

export type TasteProfile = {
  languages: string[];
  genres: string[];
  artists: string[];
  moods: string[];
  eras: string[];
  onboardingCompleted: boolean;
  updatedAt: number;
};

export type RecommendationMode = "seed" | "blended" | "behavior";

export type HomeRecommendationResult = {
  primarySection?: HomeSection;
  rankedProviderSections: HomeSection[];
  personalizedSections: HomeSection[];
  mode: RecommendationMode;
  rationale: string;
};

export type RecommendationContext = {
  tasteProfile: TasteProfile;
  providerSections: HomeSection[];
  seededTracks: Track[];
  recentlyPlayed: Track[];
  likedSongs: Track[];
  fallbackProvider: MusicProvider;
};

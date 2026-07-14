import type { HomeRecommendationResult, RecommendationContext, RecommendationMode, TasteProfile } from "@/modules/recommendations/types";
import type { Artwork } from "@/types/artwork";
import type { HomeSection, MediaItem } from "@/types/home";
import type { Track } from "@/types/track";

const LOW_HISTORY_THRESHOLD = 6;
const BLENDED_HISTORY_THRESHOLD = 18;

const normalize = (value: string) => value.trim().toLowerCase();

const tokenize = (...values: (string | undefined)[]) =>
  values
    .flatMap((value) => (value ? normalize(value).split(/[^a-z0-9]+/i) : []))
    .filter((value) => value.length > 1);

const normalizeArtwork = (artwork: Track["artwork"]): Artwork | undefined =>
  artwork && typeof artwork !== "string" ? artwork : undefined;

const uniqueStrings = (values: string[]) => [...new Set(values.map(normalize).filter(Boolean))];

const uniqueTracks = (tracks: Track[]) => {
  const seen = new Set<string>();
  return tracks.filter((track) => {
    const key = `${track.provider}:${track.id}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
};

const buildProfileKeywords = (tasteProfile: TasteProfile) => ({
  artists: uniqueStrings(tasteProfile.artists),
  keywords: uniqueStrings([
    ...tasteProfile.languages,
    ...tasteProfile.genres,
    ...tasteProfile.artists,
    ...tasteProfile.moods,
    ...tasteProfile.eras,
  ]),
});

const buildBehaviorKeywords = (recentlyPlayed: Track[], likedSongs: Track[]) => {
  const history = uniqueTracks([...recentlyPlayed, ...likedSongs]);
  return {
    artists: uniqueStrings(history.flatMap((track) => track.artists?.length ? track.artists : [track.artist])),
    keywords: uniqueStrings(
      history.flatMap((track) => tokenize(track.title, track.artist, track.album, ...(track.artists ?? []))),
    ),
  };
};

const inferMode = (historyCount: number): RecommendationMode => {
  if (historyCount >= BLENDED_HISTORY_THRESHOLD) {
    return "behavior";
  }
  if (historyCount >= LOW_HISTORY_THRESHOLD) {
    return "blended";
  }
  return "seed";
};

const scoreTokenOverlap = (haystack: string[], needles: string[], weight: number) =>
  needles.reduce((score, needle) => score + (haystack.includes(needle) ? weight : 0), 0);

const scoreTrack = (track: Track, tasteProfile: TasteProfile, recentlyPlayed: Track[], likedSongs: Track[]) => {
  const historyCount = recentlyPlayed.length + likedSongs.length;
  const mode = inferMode(historyCount);
  const tasteWeight = mode === "seed" ? 1 : mode === "blended" ? 0.7 : 0.45;
  const behaviorWeight = mode === "behavior" ? 0.8 : mode === "blended" ? 0.55 : 0.25;
  const profile = buildProfileKeywords(tasteProfile);
  const behavior = buildBehaviorKeywords(recentlyPlayed, likedSongs);
  const tokens = uniqueStrings(tokenize(track.title, track.artist, track.album, ...(track.artists ?? [])));
  const artistTokens = uniqueStrings(track.artists?.length ? track.artists : [track.artist]);

  return (
    scoreTokenOverlap(artistTokens, profile.artists, 12) * tasteWeight +
    scoreTokenOverlap(tokens, profile.keywords, 3) * tasteWeight +
    scoreTokenOverlap(artistTokens, behavior.artists, 7) * behaviorWeight +
    scoreTokenOverlap(tokens, behavior.keywords, 2) * behaviorWeight
  );
};

const scoreMediaItem = (item: MediaItem, tasteProfile: TasteProfile, recentlyPlayed: Track[], likedSongs: Track[]) => {
  const baseTokens = uniqueStrings(tokenize(item.title, item.subtitle));
  const profile = buildProfileKeywords(tasteProfile);
  const behavior = buildBehaviorKeywords(recentlyPlayed, likedSongs);
  const trackScore = item.track ? scoreTrack(item.track, tasteProfile, recentlyPlayed, likedSongs) : 0;

  return (
    trackScore +
    scoreTokenOverlap(baseTokens, profile.keywords, 2) +
    scoreTokenOverlap(baseTokens, behavior.keywords, 1.25)
  );
};

const scoreSection = (section: HomeSection, tasteProfile: TasteProfile, recentlyPlayed: Track[], likedSongs: Track[]) => {
  const itemScores = section.items.map((item) => scoreMediaItem(item, tasteProfile, recentlyPlayed, likedSongs));
  const topItems = itemScores.sort((left, right) => right - left).slice(0, 4);
  const averageItemScore = topItems.length ? topItems.reduce((sum, score) => sum + score, 0) / topItems.length : 0;
  const titleTokens = uniqueStrings(tokenize(section.title, section.subtitle));
  const profile = buildProfileKeywords(tasteProfile);
  const behavior = buildBehaviorKeywords(recentlyPlayed, likedSongs);

  return (
    averageItemScore +
    scoreTokenOverlap(titleTokens, profile.keywords, 2.5) +
    scoreTokenOverlap(titleTokens, behavior.keywords, 1.5)
  );
};

const buildPrimarySection = ({
  tasteProfile,
  seededTracks,
  providerSections,
  recentlyPlayed,
  likedSongs,
  fallbackProvider,
}: RecommendationContext): HomeSection | undefined => {
  const recentIds = new Set(recentlyPlayed.map((track) => `${track.provider}:${track.id}`));
  const providerTracks = providerSections.flatMap((section) => section.items.map((item) => item.track).filter(Boolean) as Track[]);
  const scoredTracks = uniqueTracks([...seededTracks, ...providerTracks])
    .filter((track) => !recentIds.has(`${track.provider}:${track.id}`))
    .map((track) => ({
      track,
      score: scoreTrack(track, tasteProfile, recentlyPlayed, likedSongs),
    }))
    .sort((left, right) => right.score - left.score);

  const topTracks = scoredTracks.slice(0, 12).map((entry) => entry.track);
  if (!topTracks.length) {
    return undefined;
  }

  return {
    id: "taste-primary-recommendations",
    provider: topTracks[0]?.provider ?? fallbackProvider,
    title: "Recommended For You",
    subtitle:
      scoredTracks[0]?.score > 0
        ? "Built from your taste profile and tuned by what you actually play."
        : "We are starting with the strongest shelves available while your recommendations learn.",
    cardType: "track_list",
    items: topTracks.map((track) => ({
      id: `recommended-${track.provider}-${track.id}`,
      provider: track.provider,
      kind: "track",
      title: track.title,
      subtitle: track.artist,
      artwork: normalizeArtwork(track.artwork),
      track,
      isPlayable: true,
    })),
  };
};

export const buildTasteSeedQueries = (tasteProfile: TasteProfile) => {
  const artists = tasteProfile.artists.slice(0, 4);
  const genres = tasteProfile.genres.slice(0, 3);
  const languages = tasteProfile.languages.slice(0, 2);
  const moods = tasteProfile.moods.slice(0, 2);
  const eras = tasteProfile.eras.slice(0, 2);
  const queries = [
    ...artists,
    ...artists.flatMap((artist) => genres.slice(0, 2).map((genre) => `${artist} ${genre}`)),
    ...languages.flatMap((language) => genres.slice(0, 2).map((genre) => `${language} ${genre}`)),
    ...moods.map((mood) => `${mood} music`),
    ...eras.map((era) => `${era} hits`),
  ];

  return [...new Set(queries.map((query) => query.trim()).filter(Boolean))].slice(0, 8);
};

export const buildHomeRecommendationResult = (context: RecommendationContext): HomeRecommendationResult => {
  const historyCount = context.recentlyPlayed.length + context.likedSongs.length;
  const mode = inferMode(historyCount);
  const rankedProviderSections = context.providerSections
    .map((section, index) => ({
      section,
      index,
      score: scoreSection(section, context.tasteProfile, context.recentlyPlayed, context.likedSongs),
    }))
    .sort((left, right) => right.score - left.score || left.index - right.index)
    .map((entry) => entry.section);

  const primarySection = buildPrimarySection(context);
  const personalizedSections = primarySection ? [primarySection] : [];

  const rationale =
    mode === "seed"
      ? "Using your selected taste profile until you build enough listening history."
      : mode === "blended"
        ? "Blending your saved taste profile with your recent listening patterns."
        : "Your listening behavior now leads, with your taste profile still shaping discovery.";

  return {
    primarySection,
    rankedProviderSections,
    personalizedSections,
    mode,
    rationale,
  };
};

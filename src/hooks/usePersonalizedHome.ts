import { useQuery } from "@tanstack/react-query";
import { useMemo } from "react";

import { useHomeSections } from "@/hooks/useHomeSections";
import { buildHomeRecommendationResult, buildTasteSeedQueries } from "@/modules/recommendations/recommendationService";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useSettingsStore } from "@/modules/settings/settingsStore";

export const usePersonalizedHome = () => {
  const preferredHomeProvider = useSettingsStore((state) => state.preferredHomeProvider);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const tasteProfile = useTasteProfileStore((state) => state.tasteProfile);
  const recentlyPlayed = useLibraryStore((state) => state.recentlyPlayed);
  const likedSongs = useLibraryStore((state) => state.likedSongs);
  const providerQuery = useHomeSections();
  const seedQueries = useMemo(() => buildTasteSeedQueries(tasteProfile), [tasteProfile]);
  const activeSeedProvider = providerStates[preferredHomeProvider] ? preferredHomeProvider : "all";

  const seedQuery = useQuery({
    queryKey: ["taste-seeds", activeSeedProvider, tasteProfile.updatedAt, seedQueries],
    enabled: tasteProfile.onboardingCompleted && seedQueries.length > 0,
    staleTime: 30 * 60 * 1000,
    gcTime: 60 * 60 * 1000,
    queryFn: async () => {
      const settled = await Promise.allSettled(
        seedQueries.map((query) => sourceRegistry.search(query, activeSeedProvider)),
      );

      return settled.flatMap((result) => (result.status === "fulfilled" ? result.value : []));
    },
  });

  const recommendationResult = useMemo(
    () =>
      buildHomeRecommendationResult({
        tasteProfile,
        providerSections: providerQuery.data ?? [],
        seededTracks: seedQuery.data ?? [],
        recentlyPlayed,
        likedSongs,
        fallbackProvider: preferredHomeProvider,
      }),
    [likedSongs, preferredHomeProvider, providerQuery.data, recentlyPlayed, seedQuery.data, tasteProfile],
  );

  return {
    providerQuery,
    seedQuery,
    recommendationResult,
  };
};

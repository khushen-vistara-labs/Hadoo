import { useQuery } from "@tanstack/react-query";

import { useSettingsStore } from "@/modules/settings/settingsStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";

const HOME_CACHE_TTL_MS = 2 * 60 * 60 * 1000;

export const useHomeSections = () => {
  const preferredHomeProvider = useSettingsStore((state) => state.preferredHomeProvider);

  return useQuery({
    queryKey: ["home-sections", preferredHomeProvider],
    queryFn: () => sourceRegistry.getHomeSections(preferredHomeProvider),
    staleTime: HOME_CACHE_TTL_MS,
    gcTime: HOME_CACHE_TTL_MS * 2,
  });
};

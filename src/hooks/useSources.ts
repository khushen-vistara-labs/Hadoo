import { keepPreviousData, useQuery } from "@tanstack/react-query";

import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import type { ProviderFilter } from "@/types/source";

export const useSourceSearch = (query: string, provider: ProviderFilter) => {
  const normalizedQuery = query.trim();

  return useQuery({
    queryKey: ["search", provider, normalizedQuery],
    queryFn: () => sourceRegistry.search(normalizedQuery, provider),
    enabled: normalizedQuery.length >= 2 || provider === "mock",
    staleTime: 60_000,
    placeholderData: keepPreviousData,
  });
};

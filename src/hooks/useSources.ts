import { useQuery } from "@tanstack/react-query";

import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import type { ProviderFilter } from "@/types/source";

export const useSourceSearch = (query: string, provider: ProviderFilter) =>
  useQuery({
    queryKey: ["search", provider, query],
    queryFn: () => sourceRegistry.search(query, provider),
    enabled: query.trim().length > 0 || provider === "mock",
    staleTime: 60_000,
  });

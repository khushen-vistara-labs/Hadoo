import type { ProviderStatus } from "@/types/source";
import type { MusicProvider } from "@/types/source";
import type { Track } from "@/types/track";

import type { SourceCapabilities } from "@/modules/sources/sourceModels";

export interface MusicSource extends SourceCapabilities {
  id: MusicProvider;
  name: string;
  status: ProviderStatus;
  search(query: string): Promise<Track[]>;
}

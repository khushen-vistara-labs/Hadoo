import type { MusicSource } from "@/modules/sources/MusicSource";
import type { StreamSource, Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

export class ExperimentalJioSaavnSource implements MusicSource {
  id = "jiosaavn_experimental" as const;
  name = "JioSaavn Experimental";
  status = "not_implemented" as const;

  async search(_query: string): Promise<Track[]> {
    // TODO: Add provider-specific search logic here using a private adapter.
    return [];
  }

  async getTrackDetails(_localId: string): Promise<Track> {
    throw new SourceUnavailableError("Provider needs update.");
  }

  async getStreams(_localId: string): Promise<StreamSource[]> {
    // TODO: Resolve provider-specific playback URLs here when a compliant adapter exists.
    throw new SourceUnavailableError("Provider needs update.");
  }
}

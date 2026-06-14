import type { MusicSource } from "@/modules/sources/MusicSource";
import type { StreamSource, Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

export class CachedMusicSource implements MusicSource {
  id = "cached" as const;
  name = "Cached";
  status = "not_implemented" as const;

  async search(_query: string): Promise<Track[]> {
    return [];
  }

  async getTrackDetails(_localId: string): Promise<Track> {
    throw new SourceUnavailableError("Cached playback is not implemented yet.");
  }

  async getStreams(_localId: string): Promise<StreamSource[]> {
    throw new SourceUnavailableError("Cached playback is not implemented yet.");
  }
}

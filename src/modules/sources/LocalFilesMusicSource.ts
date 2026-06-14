import type { MusicSource } from "@/modules/sources/MusicSource";
import type { StreamSource, Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

export class LocalFilesMusicSource implements MusicSource {
  id = "local" as const;
  name = "Local Files";
  status = "needs_update" as const;

  async search(_query: string): Promise<Track[]> {
    return [];
  }

  async getTrackDetails(_localId: string): Promise<Track> {
    throw new SourceUnavailableError("Local files are not configured yet.");
  }

  async getStreams(_localId: string): Promise<StreamSource[]> {
    throw new SourceUnavailableError("Local files are not configured yet.");
  }
}

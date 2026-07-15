import type { MusicSource } from "@/modules/sources/MusicSource";
import type { MusicProvider } from "@/types/source";
import type { Track } from "@/types/track";
import { SourceUnavailableError } from "@/utils/errors";

type PlaceholderCatalogSourceOptions = {
  id: MusicProvider;
  name: string;
  status?: "not_implemented" | "needs_update";
};

export class PlaceholderCatalogSource implements MusicSource {
  id: MusicProvider;
  name: string;
  status: "not_implemented" | "needs_update";

  constructor({ id, name, status = "not_implemented" }: PlaceholderCatalogSourceOptions) {
    this.id = id;
    this.name = name;
    this.status = status;
  }

  async search(_query: string): Promise<Track[]> {
    return [];
  }

  async getTrackDetails(): Promise<Track> {
    throw new SourceUnavailableError(`${this.name} is not wired yet.`);
  }
}

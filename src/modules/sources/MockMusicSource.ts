import { mockLyrics, mockTracks } from "@/data/mockTracks";
import type { MusicSource } from "@/modules/sources/MusicSource";
import { buildScopedTrackId } from "@/modules/sources/sourceUtils";
import type { StreamSource, Track } from "@/types/track";
import { StreamResolveError } from "@/utils/errors";

export class MockMusicSource implements MusicSource {
  id = "mock" as const;
  name = "Mock";
  status = "enabled" as const;

  async search(query: string): Promise<Track[]> {
    const normalized = query.trim().toLowerCase();
    if (!normalized) {
      return mockTracks.map((track) => this.toScopedTrack(track));
    }

    return mockTracks
      .filter((track) => `${track.title} ${track.artist} ${track.album ?? ""}`.toLowerCase().includes(normalized))
      .map((track) => this.toScopedTrack(track));
  }

  async getTrackDetails(localId: string): Promise<Track> {
    const track = mockTracks.find((item) => item.id === localId || item.localId === localId);
    if (!track) {
      throw new StreamResolveError("Mock track not found.");
    }

    return this.toScopedTrack(track);
  }

  async getStreams(localId: string): Promise<StreamSource[]> {
    const track = await this.getTrackDetails(localId);

    if (!track.streamUrl) {
      throw new StreamResolveError("Mock track missing stream URL.");
    }

    return [{ url: track.streamUrl, quality: track.quality ?? "high" }];
  }

  async getLyrics(track: Track) {
    const localId = track.localId ?? track.id;
    return mockLyrics[localId] ?? [{ text: "Lyrics are not available for this track yet." }];
  }

  async getRelated(track: Track) {
    const localId = track.localId ?? track.id;
    return mockTracks
      .filter((item) => item.id !== localId)
      .slice(0, 4)
      .map((item) => this.toScopedTrack(item));
  }

  private toScopedTrack(track: Track): Track {
    const localId = track.localId ?? track.id;

    return {
      ...track,
      id: buildScopedTrackId(this.id, localId),
      provider: this.id,
      localId,
    };
  }
}

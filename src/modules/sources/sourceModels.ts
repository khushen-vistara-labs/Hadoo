import type { LyricLine, StreamSource, Track } from "@/types/track";
import type { ArtworkLike } from "@/types/artwork";
import type { HomeSection } from "@/types/home";

export type ImportedCollection = {
  id: string;
  title: string;
  sourceUrl: string;
  artwork?: ArtworkLike;
};

export type ImportResult = {
  collection: ImportedCollection;
  tracks: Track[];
};

export interface UrlTrackResolver {
  canHandleUrl(url: string): boolean;
  resolveTrackFromUrl(url: string): Promise<Track>;
}

export interface StreamProvider {
  getTrackDetails(localId: string): Promise<Track>;
  getStreams(localId: string): Promise<StreamSource[]>;
}

export interface CollectionImporter {
  canImportUrl(url: string): boolean;
  importFromUrl(url: string): Promise<ImportResult>;
}

export interface HomeContentProvider {
  getHomeSections?(): Promise<HomeSection[]>;
}

export type SourceCapabilities = Partial<UrlTrackResolver & StreamProvider & CollectionImporter & HomeContentProvider> & {
  getLyrics?(track: Track): Promise<LyricLine[]>;
  getRelated?(track: Track): Promise<Track[]>;
};

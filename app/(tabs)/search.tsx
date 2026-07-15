import { LinearGradient } from "expo-linear-gradient";
import { memo, useEffect, useMemo, useState } from "react";
import { ActivityIndicator, FlatList, Pressable, ScrollView, StyleSheet, TextInput, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { AddToPlaylistSheet } from "@/components/playlists/AddToPlaylistSheet";
import { Chip } from "@/components/ui/Chip";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useSourceSearch } from "@/hooks/useSources";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { toastService } from "@/services/toastService";
import type { ProviderFilter } from "@/types/source";
import type { Track } from "@/types/track";
import { formatDuration } from "@/utils/formatDuration";

const filters: { id: ProviderFilter; label: string }[] = [
  { id: "all", label: "All" },
  { id: "youtube_music_experimental", label: "YouTube Music" },
  { id: "youtube_experimental", label: "YouTube" },
  { id: "spotify_experimental", label: "Spotify" },
  { id: "soundcloud_experimental", label: "SoundCloud" },
  { id: "deezer_experimental", label: "Deezer" },
  { id: "tidal_experimental", label: "Tidal" },
  { id: "amazon_music_experimental", label: "Amazon Music" },
  { id: "jiosaavn_experimental", label: "JioSaavn Experimental" },
  { id: "local", label: "Local" },
];

type SearchResultRowProps = {
  track: Track;
  onPress: () => void;
  onLongPress: () => void;
};

const SearchResultRow = memo(({ track, onPress, onLongPress }: SearchResultRowProps) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={onPress}
      onLongPress={onLongPress}
      delayLongPress={220}
      style={({ pressed }) => [
        styles.resultRow,
        {
          backgroundColor: pressed ? theme.surfaceAlt : theme.card,
          borderColor: pressed ? theme.accent : `${theme.border}CC`,
        },
      ]}
    >
      <LinearGradient
        colors={[`${theme.accent}22`, `${theme.accentAlt}08`, "transparent"]}
        start={{ x: 0, y: 0.5 }}
        end={{ x: 1, y: 0.5 }}
        style={styles.resultGlow}
      />
      <CachedArtwork artwork={track.artwork} category="track" variant="thumbnail" width={58} height={58} borderRadius={18} />
      <View style={styles.resultMeta}>
        <Text numberOfLines={2} style={styles.resultTitle}>
          {track.title}
        </Text>
        <Text muted numberOfLines={1}>
          {track.artist}
        </Text>
        <View style={styles.resultTags}>
          {track.album ? (
            <View style={[styles.tag, { backgroundColor: `${theme.surfaceAlt}CC` }]}>
              <Text muted numberOfLines={1} style={styles.tagText}>
                {track.album}
              </Text>
            </View>
          ) : null}
          <View style={[styles.tag, { backgroundColor: `${theme.accent}1F` }]}>
            <Text style={[styles.tagText, { color: theme.accent }]}>{providerLabels[track.provider]}</Text>
          </View>
        </View>
      </View>
      <View style={styles.resultSide}>
        <Text muted>{formatDuration(track.duration)}</Text>
      </View>
    </Pressable>
  );
});

SearchResultRow.displayName = "SearchResultRow";

export default function SearchScreen() {
  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [provider, setProvider] = useState<ProviderFilter>("all");
  const [selectedTrack, setSelectedTrack] = useState<Track | null>(null);
  const [playlistTrack, setPlaylistTrack] = useState<Track | null>(null);
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const normalizedQuery = query.trim();

  useEffect(() => {
    const timeout = setTimeout(() => {
      setDebouncedQuery(normalizedQuery);
    }, 220);

    return () => clearTimeout(timeout);
  }, [normalizedQuery]);

  const { data, isLoading, isFetching, isError } = useSourceSearch(debouncedQuery, provider);
  const results = data ?? [];
  const hasTypedQuery = normalizedQuery.length > 0;
  const canSearch = debouncedQuery.length >= 2;
  const statusText = useMemo(() => {
    if (!hasTypedQuery) {
      return "Start with a song, artist, album, or paste a supported link.";
    }

    if (!canSearch) {
      return "Type at least 2 characters to search.";
    }

    if (isError) {
      return "This source is unavailable right now.";
    }

    if (isLoading && !results.length) {
      return "Searching across your music sources...";
    }

    if (!results.length) {
      return "No matches yet. Try a different source or a more specific search.";
    }

    return `${results.length} result${results.length === 1 ? "" : "s"}. Press and hold for details.`;
  }, [canSearch, hasTypedQuery, isError, isLoading, results.length]);

  return (
    <Screen scroll={false} contentContainerStyle={styles.screenContent}>
      <View pointerEvents="none" style={styles.backgroundOrbs}>
        <View style={[styles.orb, styles.orbOne, { backgroundColor: theme.accent }]} />
        <View style={[styles.orb, styles.orbTwo, { backgroundColor: theme.accentAlt }]} />
      </View>
      <FlatList
        data={results}
        keyExtractor={(track) => track.id}
        keyboardShouldPersistTaps="handled"
        keyboardDismissMode="on-drag"
        removeClippedSubviews
        initialNumToRender={8}
        maxToRenderPerBatch={10}
        windowSize={8}
        contentContainerStyle={[styles.listContent, { paddingBottom: styles.listContent.paddingBottom + contentBottomSpacing }]}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        ListHeaderComponent={
          <View style={styles.header}>
            <View style={styles.titleBlock}>
              <Text muted variant="caption" style={[styles.eyebrow, { color: theme.accent }]}>
                Search
              </Text>
              <Text variant="title">Find tracks without the clutter.</Text>
              <Text muted style={styles.subtitle}>
                Search cleanly, skim faster, and open full track details when you need them.
              </Text>
            </View>

            <LinearGradient
              style={[
                styles.searchCard,
                {
                  borderColor: `${theme.border}D9`,
                },
              ]}
              colors={[`${theme.accent}1A`, `${theme.accentAlt}12`, `${theme.surface}F2`]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <View style={[styles.inputShell, { backgroundColor: `${theme.background}B8`, borderColor: `${theme.border}66` }]}>
                <TextInput
                  value={query}
                  onChangeText={setQuery}
                  onSubmitEditing={async () => {
                    try {
                      const resolved = await sourceRegistry.resolveUrlIntent(query, provider);
                      if (!resolved.length) {
                        return;
                      }

                      if (resolved.length === 1) {
                        await playerService.playTrack(resolved[0], resolved);
                        return;
                      }

                      toastService.show(`Imported ${resolved.length} tracks from the link.`);
                    } catch {
                      toastService.show("Could not resolve this link.");
                    }
                  }}
                  placeholder="Search tracks, artists, albums"
                  placeholderTextColor={theme.textMuted}
                  selectionColor={theme.accent}
                  style={[
                    styles.input,
                    {
                      color: theme.text,
                    },
                  ]}
                />
              </View>
              <View style={styles.searchMeta}>
                <Text muted>{statusText}</Text>
                {isFetching && canSearch ? <ActivityIndicator size="small" color={theme.accent} /> : null}
              </View>
              {results.length ? (
                <View style={styles.helperRow}>
                  <Text muted style={styles.helperText}>
                    Press and hold any result to view full details.
                  </Text>
                </View>
              ) : null}
            </LinearGradient>

            <View style={styles.chips}>
              {filters.map((item) => (
                <Chip key={item.id} label={item.label} active={provider === item.id} onPress={() => setProvider(item.id)} />
              ))}
            </View>
          </View>
        }
        ListEmptyComponent={
          <View
            style={[
              styles.emptyState,
              {
                backgroundColor: `${theme.card}E8`,
                borderColor: `${theme.border}99`,
              },
            ]}
          >
            <Text variant="headline">
              {!hasTypedQuery ? "Start with a song, artist, or album." : canSearch ? "No results yet." : "Keep typing."}
            </Text>
            <Text muted>{statusText}</Text>
          </View>
        }
        renderItem={({ item: track }) => (
          <SearchResultRow
            track={track}
            onPress={() =>
              playerService.playTrack(track).catch(() => {
                toastService.show("Could not play this track.");
              })
            }
            onLongPress={() => setSelectedTrack(track)}
          />
        )}
      />
      {selectedTrack ? (
        <View style={styles.overlay}>
          <Pressable style={styles.backdrop} onPress={() => setSelectedTrack(null)} />
          <ScrollView
            bounces={false}
            showsVerticalScrollIndicator={false}
            style={[
              styles.detailSheet,
              {
                backgroundColor: theme.background,
                marginBottom: Math.max(insets.bottom, 8) + contentBottomSpacing,
              },
            ]}
            contentContainerStyle={[
              styles.detailSheetContent,
              {
                paddingBottom: 24,
              },
            ]}
          >
            <View style={[styles.sheetHandle, { backgroundColor: theme.textMuted }]} />
            <View style={styles.detailTopBar}>
              <Text muted variant="caption" style={styles.detailTopTitle}>
                Track Details
              </Text>
              <Pressable onPress={() => setSelectedTrack(null)} style={styles.detailCloseButton}>
                <Text style={{ color: theme.accent }}>Close</Text>
              </Pressable>
            </View>
            <View style={styles.detailHeader}>
              <CachedArtwork
                artwork={selectedTrack.artwork}
                category="track"
                variant="thumbnail"
                width={72}
                height={72}
                borderRadius={22}
              />
              <View style={styles.detailMeta}>
                <Text variant="headline" style={styles.detailTitle}>
                  {selectedTrack.title}
                </Text>
                <Text muted>{selectedTrack.artist}</Text>
              </View>
            </View>
            <View style={styles.detailGrid}>
              <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
                <Text muted variant="caption">
                  Provider
                </Text>
                <Text>{providerLabels[selectedTrack.provider]}</Text>
              </View>
              <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
                <Text muted variant="caption">
                  Duration
                </Text>
                <Text>{formatDuration(selectedTrack.duration)}</Text>
              </View>
              {selectedTrack.quality ? (
                <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
                  <Text muted variant="caption">
                    Quality
                  </Text>
                  <Text>{selectedTrack.quality}</Text>
                </View>
              ) : null}
              {selectedTrack.isExplicit ? (
                <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
                  <Text muted variant="caption">
                    Marking
                  </Text>
                  <Text>Explicit</Text>
                </View>
              ) : null}
            </View>
            {selectedTrack.album ? (
              <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
                <Text muted variant="caption">
                  Album
                </Text>
                <Text>{selectedTrack.album}</Text>
              </View>
            ) : null}
            {selectedTrack.sourceUrl ? (
              <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
                <Text muted variant="caption">
                  Source Link
                </Text>
                <Text numberOfLines={2}>{selectedTrack.sourceUrl}</Text>
              </View>
            ) : null}
            <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
              <Text muted variant="caption">
                Playlists
              </Text>
              <View style={styles.playlistActions}>
                <Pressable
                  onPress={() => setPlaylistTrack(selectedTrack)}
                  style={[styles.playlistActionButton, { borderColor: theme.accent, backgroundColor: `${theme.accent}14` }]}
                >
                  <Text style={{ color: theme.accent }}>Add to playlist</Text>
                </Pressable>
                <Text muted>Pick a playlist or create a new one.</Text>
              </View>
            </View>
          </ScrollView>
        </View>
      ) : null}
      <AddToPlaylistSheet
        visible={Boolean(playlistTrack)}
        track={playlistTrack}
        onClose={() => setPlaylistTrack(null)}
        bottomOffset={92}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  screenContent: {
    flex: 1,
    padding: 0,
    gap: 0,
  },
  backgroundOrbs: {
    ...StyleSheet.absoluteFillObject,
    overflow: "hidden",
  },
  orb: {
    position: "absolute",
    width: 260,
    height: 260,
    borderRadius: 999,
    opacity: 0.1,
  },
  orbOne: {
    top: -40,
    right: -90,
  },
  orbTwo: {
    top: 120,
    left: -120,
  },
  listContent: {
    padding: 20,
    paddingBottom: 120,
    gap: 14,
  },
  header: {
    gap: 20,
    paddingBottom: 22,
  },
  titleBlock: {
    gap: 8,
  },
  eyebrow: {
    letterSpacing: 1.2,
  },
  subtitle: {
    maxWidth: "88%",
  },
  searchCard: {
    borderRadius: 32,
    borderWidth: 1,
    padding: 14,
    gap: 12,
    overflow: "hidden",
  },
  inputShell: {
    borderRadius: 22,
    borderWidth: 1,
    paddingHorizontal: 16,
  },
  input: {
    paddingVertical: 14,
    fontSize: 16,
  },
  searchMeta: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  helperRow: {
    paddingTop: 2,
  },
  helperText: {
    fontSize: 12,
  },
  chips: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  separator: {
    height: 14,
  },
  resultRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    borderRadius: 28,
    borderWidth: 1,
    padding: 14,
    overflow: "hidden",
  },
  resultGlow: {
    ...StyleSheet.absoluteFillObject,
  },
  resultMeta: {
    flex: 1,
    gap: 5,
  },
  resultTitle: {
    fontSize: 16,
    lineHeight: 21,
  },
  resultTags: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    marginTop: 2,
  },
  tag: {
    maxWidth: "100%",
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  tagText: {
    fontSize: 11,
  },
  resultSide: {
    alignItems: "flex-end",
    minWidth: 44,
  },
  emptyState: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 20,
    gap: 10,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "flex-end",
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.42)",
  },
  detailSheet: {
    flexGrow: 0,
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    maxHeight: "68%",
  },
  detailSheetContent: {
    paddingHorizontal: 20,
    paddingTop: 16,
    gap: 18,
  },
  sheetHandle: {
    alignSelf: "center",
    width: 42,
    height: 5,
    borderRadius: 999,
    opacity: 0.5,
  },
  detailTopBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  detailTopTitle: {
    letterSpacing: 1.1,
  },
  detailCloseButton: {
    paddingVertical: 4,
  },
  detailHeader: {
    flexDirection: "row",
    gap: 14,
    alignItems: "center",
  },
  detailMeta: {
    flex: 1,
    gap: 4,
  },
  detailTitle: {
    lineHeight: 25,
  },
  detailGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  detailPill: {
    minWidth: 110,
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 12,
    gap: 4,
  },
  detailBlock: {
    borderRadius: 22,
    borderWidth: 1,
    padding: 16,
    gap: 6,
  },
  playlistActions: {
    gap: 10,
    marginTop: 4,
  },
  playlistActionButton: {
    borderWidth: 1,
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
});

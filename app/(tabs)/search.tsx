import { useState } from "react";
import { Pressable, StyleSheet, TextInput, View } from "react-native";

import { TrackRow } from "@/components/player/TrackRow";
import { Chip } from "@/components/ui/Chip";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useSourceSearch } from "@/hooks/useSources";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { toastService } from "@/services/toastService";
import type { ProviderFilter } from "@/types/source";

const filters: { id: ProviderFilter; label: string }[] = [
  { id: "all", label: "All" },
  { id: "mock", label: "Mock" },
  { id: "youtube_music_experimental", label: "YouTube" },
  { id: "jiosaavn_experimental", label: "JioSaavn Experimental" },
  { id: "local", label: "Local" },
];

export default function SearchScreen() {
  const [query, setQuery] = useState("solar");
  const [provider, setProvider] = useState<ProviderFilter>("all");
  const theme = useTheme();
  const { data, isLoading, isError } = useSourceSearch(query, provider);

  return (
    <Screen>
      <Text variant="title">Search</Text>
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
        style={[
          styles.input,
          {
            color: theme.text,
            backgroundColor: theme.surface,
            borderColor: theme.border,
          },
        ]}
      />
      <View style={styles.chips}>
        {filters.map((item) => (
          <Chip key={item.id} label={item.label} active={provider === item.id} onPress={() => setProvider(item.id)} />
        ))}
      </View>

      {isLoading ? <Text muted>Loading search results...</Text> : null}
      {isError ? <Text muted>This source is currently unavailable.</Text> : null}
      {!isLoading && !isError && !data?.length ? <Text muted>No results yet. Try another source.</Text> : null}

      <View style={styles.results}>
        {data?.map((track) => (
          <TrackRow
            key={track.id}
            track={track}
            onPress={() =>
              playerService.playTrack(track).catch(() => {
                toastService.show("Could not play this track.");
              })
            }
          />
        ))}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  input: {
    borderRadius: 18,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
  },
  chips: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  results: {
    gap: 12,
  },
});

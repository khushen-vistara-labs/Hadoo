import { Pressable, StyleSheet, TextInput, View } from "react-native";

import { Chip } from "@/components/ui/Chip";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";

export const SelectableArtistChips = ({
  selected,
  suggestions,
  query,
  onQueryChange,
  onToggleArtist,
  onAddTypedArtist,
  loading,
  providerUnavailable,
}: {
  selected: string[];
  suggestions: string[];
  query: string;
  onQueryChange: (value: string) => void;
  onToggleArtist: (artist: string) => void;
  onAddTypedArtist: () => void;
  loading?: boolean;
  providerUnavailable?: boolean;
}) => {
  const theme = useTheme();

  return (
    <View style={styles.container}>
      <View style={[styles.searchBox, { backgroundColor: theme.surface, borderColor: theme.border }]}>
        <TextInput
          value={query}
          onChangeText={onQueryChange}
          placeholder="Search or type an artist"
          placeholderTextColor={theme.textMuted}
          style={[styles.input, { color: theme.text }]}
          autoCapitalize="words"
          autoCorrect={false}
        />
        <Pressable onPress={onAddTypedArtist} disabled={!query.trim()}>
          <Text style={{ color: query.trim() ? theme.accent : theme.textMuted }}>Add</Text>
        </Pressable>
      </View>

      {selected.length ? (
        <View style={styles.group}>
          <Text muted>Your picks</Text>
          <View style={styles.wrap}>
            {selected.map((artist) => (
              <Chip key={artist} label={artist} active onPress={() => onToggleArtist(artist)} />
            ))}
          </View>
        </View>
      ) : null}

      <View style={styles.group}>
        <Text muted>
          {loading
            ? "Finding artists from your active provider..."
            : providerUnavailable
              ? "Search is unavailable right now. Typed chips still work."
              : "Tap suggestions from search, or add your own artists."}
        </Text>
        <View style={styles.wrap}>
          {suggestions.map((artist) => (
            <Chip key={artist} label={artist} active={selected.includes(artist)} onPress={() => onToggleArtist(artist)} />
          ))}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    gap: 16,
  },
  searchBox: {
    borderWidth: 1,
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 4,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  input: {
    flex: 1,
    minHeight: 44,
    fontSize: 15,
  },
  group: {
    gap: 10,
  },
  wrap: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
});

import { memo } from "react";
import { Pressable, StyleSheet, View } from "react-native";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { providerLabels } from "@/constants/providers";
import { useTheme } from "@/hooks/useTheme";
import { Text } from "@/components/ui/Text";
import { formatDuration } from "@/utils/formatDuration";
import type { Track } from "@/types/track";

type Props = {
  track: Track;
  onPress: () => void;
};

export const TrackRow = memo(({ track, onPress }: Props) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.row,
        {
          backgroundColor: pressed ? theme.surfaceAlt : theme.surface,
          borderColor: theme.border,
        },
      ]}
    >
      <CachedArtwork artwork={track.artwork} category="track" variant="thumbnail" width={50} height={50} borderRadius={14} />
      <View style={styles.meta}>
        <Text numberOfLines={1}>{track.title}</Text>
        <Text muted numberOfLines={1}>
          {track.artist}
        </Text>
      </View>
      <View style={styles.side}>
        <Text variant="caption" style={{ color: theme.accent }}>
          {providerLabels[track.provider]}
        </Text>
        <Text muted>{formatDuration(track.duration)}</Text>
      </View>
    </Pressable>
  );
});

TrackRow.displayName = "TrackRow";

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    padding: 12,
    borderRadius: 18,
    borderWidth: 1,
    gap: 12,
  },
  artwork: {
    width: 50,
    height: 50,
    borderRadius: 14,
  },
  meta: {
    flex: 1,
    gap: 4,
  },
  side: {
    alignItems: "flex-end",
    gap: 6,
  },
});

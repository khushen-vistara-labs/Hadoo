import { router } from "expo-router";
import { Image, Pressable, StyleSheet, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { usePlayer } from "@/hooks/usePlayer";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";

export const MiniPlayer = () => {
  const { currentTrack, isPlaying } = usePlayer();
  const theme = useTheme();

  if (!currentTrack) {
    return null;
  }

  return (
    <Pressable onPress={() => router.push("/now-playing")} style={styles.wrapper}>
      <Card style={[styles.card, { backgroundColor: theme.surface }]}>
        {currentTrack.artwork ? (
          <Image source={{ uri: currentTrack.artwork }} style={styles.thumb} />
        ) : (
          <View style={[styles.thumb, { backgroundColor: theme.surfaceAlt }]} />
        )}
        <View style={styles.meta}>
          <Text numberOfLines={1}>{currentTrack.title}</Text>
          <Text muted numberOfLines={1}>
            {currentTrack.artist}
          </Text>
        </View>
        <Pressable onPress={() => (isPlaying ? playerService.pause() : playerService.resume())}>
          <SymbolIcon name={isPlaying ? "pause" : "play"} size={22} color={theme.text} />
        </Pressable>
      </Card>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: "absolute",
    left: 0,
    right: 0,
    bottom: 72,
  },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderRadius: 0,
    borderLeftWidth: 0,
    borderRightWidth: 0,
    borderBottomWidth: 0,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  thumb: {
    width: 44,
    height: 44,
    borderRadius: 12,
  },
  meta: {
    flex: 1,
    gap: 4,
  },
});

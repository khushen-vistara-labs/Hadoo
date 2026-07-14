import { router, usePathname } from "expo-router";
import { Image, Pressable, StyleSheet, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { Card } from "@/components/ui/Card";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { usePlayer } from "@/hooks/usePlayer";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";

export const MiniPlayer = () => {
  const { currentTrack, isPlaying } = usePlayer();
  const theme = useTheme();
  const pathname = usePathname();
  const insets = useSafeAreaInsets();

  if (!currentTrack) {
    return null;
  }

  const isTabScreen =
    pathname === "/" ||
    pathname.startsWith("/search") ||
    pathname.startsWith("/library") ||
    pathname.startsWith("/settings");
  const bottomOffset = isTabScreen ? 72 : insets.bottom;

  return (
    <Pressable onPress={() => router.push("/now-playing")} style={[styles.wrapper, { bottom: bottomOffset }]}>
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
        <View style={styles.actions}>
          <Pressable onPress={() => (isPlaying ? playerService.pause() : playerService.resume())}>
            <SymbolIcon name={isPlaying ? "pause" : "play"} size={22} color={theme.text} />
          </Pressable>
          {!isPlaying ? (
            <Pressable
              hitSlop={8}
              onPress={(event) => {
                event.stopPropagation();
                void playerService.dismissMiniPlayer();
              }}
            >
              <SymbolIcon name="close" size={18} color={theme.textMuted} />
            </Pressable>
          ) : null}
        </View>
      </Card>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: "absolute",
    left: 0,
    right: 0,
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
  actions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
});

import { router } from "expo-router";
import { Image, Pressable, StyleSheet, View } from "react-native";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { usePlayer } from "@/hooks/usePlayer";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";

export default function NowPlayingScreen() {
  const player = usePlayer();
  const theme = useTheme();
  const progress = player.duration ? player.progress / player.duration : 0.35;

  return (
    <Screen scroll={false}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()}>
          <SymbolIcon name="down" size={28} color={theme.text} />
        </Pressable>
        <Text muted>Now Playing</Text>
        <View style={{ width: 28 }} />
      </View>

      <Card style={[styles.hero, { backgroundColor: theme.surfaceAlt }]}>
        {player.currentTrack?.artwork ? (
          <Image source={{ uri: player.currentTrack.artwork }} style={styles.artwork} />
        ) : (
          <View style={[styles.artwork, { backgroundColor: theme.card }]} />
        )}
      </Card>

      <View style={styles.meta}>
        <Text variant="title">{player.currentTrack?.title ?? "Nothing playing"}</Text>
        <Text muted>{player.currentTrack?.artist ?? "Select a track from search or home."}</Text>
        <Text muted>{player.currentTrack?.album ?? "Mock provider"}</Text>
      </View>

      <ProgressBar progress={progress} />

      <View style={styles.controls}>
        <Pressable onPress={() => playerService.toggleShuffle()}>
          <SymbolIcon name="shuffle" size={22} color={theme.textMuted} />
        </Pressable>
        <Pressable onPress={() => playerService.skipPrevious()}>
          <SymbolIcon name="back" size={28} color={theme.text} />
        </Pressable>
        <Pressable style={[styles.primaryAction, { backgroundColor: theme.accent }]} onPress={() => (player.isPlaying ? playerService.pause() : playerService.resume())}>
          <SymbolIcon name={player.isPlaying ? "pause" : "play"} size={28} color={theme.background} />
        </Pressable>
        <Pressable onPress={() => playerService.skipNext()}>
          <SymbolIcon name="next" size={28} color={theme.text} />
        </Pressable>
        <Pressable onPress={() => playerService.toggleRepeat()}>
          <SymbolIcon name="repeat" size={22} color={theme.textMuted} />
        </Pressable>
      </View>

      <View style={styles.actions}>
        <Button label="Queue" tone="secondary" onPress={() => router.push("/queue")} />
        <Button label="Lyrics" tone="secondary" onPress={() => router.push("/lyrics")} />
        <Button label="Sleep Timer" tone="secondary" onPress={() => router.push("/sleep-timer")} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  hero: {
    padding: 18,
  },
  artwork: {
    width: "100%",
    aspectRatio: 1,
    borderRadius: 28,
  },
  meta: {
    gap: 6,
  },
  controls: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  primaryAction: {
    width: 68,
    height: 68,
    borderRadius: 34,
    alignItems: "center",
    justifyContent: "center",
  },
  actions: {
    flexDirection: "row",
    gap: 10,
  },
});

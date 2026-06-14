import { router } from "expo-router";
import { Image, Pressable, ScrollView, StyleSheet, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { SectionHeader } from "@/components/layout/SectionHeader";
import { mockTracks } from "@/data/mockTracks";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { playerService } from "@/modules/player/playerService";
import { useTheme } from "@/hooks/useTheme";

export default function HomeScreen() {
  const theme = useTheme();
  const recent = useLibraryStore((state) => state.recentlyPlayed);

  return (
    <Screen>
      <View style={styles.hero}>
        <Text variant="caption" style={{ color: theme.accent }}>
          Private listening
        </Text>
        <Text variant="title">Hadoo</Text>
        <Text muted>Fresh audio flows, modular providers, and a player built for your own devices.</Text>
      </View>

      <Card style={{ backgroundColor: theme.surfaceAlt }}>
        <Text variant="headline">Continue Listening</Text>
        {recent.slice(0, 2).map((track) => (
          <Pressable key={track.id} onPress={() => playerService.playTrack(track, recent)}>
            <Text>{track.title}</Text>
            <Text muted>{track.artist}</Text>
          </Pressable>
        ))}
      </Card>

      <SectionHeader title="Recommended" subtitle="Mock picks with safe sample streams." />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.horizontalList}>
        {mockTracks.map((track) => (
          <Pressable key={track.id} onPress={() => playerService.playTrack(track, mockTracks)}>
            <Card style={[styles.tile, { backgroundColor: theme.card }]}>
              {track.artwork ? (
                <Image source={{ uri: track.artwork }} style={styles.cover} />
              ) : (
                <View style={[styles.cover, { backgroundColor: theme.surfaceAlt }]} />
              )}
              <Text>{track.title}</Text>
              <Text muted>{track.artist}</Text>
            </Card>
          </Pressable>
        ))}
      </ScrollView>

      <SectionHeader title="Trending Mock" subtitle="Search-first architecture with curated placeholders." />
      <Card>
        <Text>Explore providers, queue tracks, and open lyrics or sleep timer from the player flow.</Text>
        <Pressable onPress={() => router.push("/source-settings")}>
          <Text style={{ color: theme.accent }}>Open source settings</Text>
        </Pressable>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  hero: {
    gap: 10,
  },
  horizontalList: {
    gap: 14,
    paddingRight: 20,
  },
  tile: {
    width: 180,
  },
  cover: {
    width: "100%",
    height: 150,
    borderRadius: 18,
  },
});

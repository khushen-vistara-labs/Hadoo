import { router } from "expo-router";
import { Pressable, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { ProviderStatusRow } from "@/components/ui/ProviderStatusRow";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { themePresets } from "@/constants/theme";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { useSettingsStore } from "@/modules/settings/settingsStore";

export default function SettingsScreen() {
  const themeId = useSettingsStore((state) => state.themeId);
  const setTheme = useSettingsStore((state) => state.setTheme);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const toggleProvider = useSettingsStore((state) => state.toggleProvider);
  const clearRecentlyPlayed = useLibraryStore((state) => state.clearRecentlyPlayed);
  const tasteProfile = useTasteProfileStore((state) => state.tasteProfile);
  const statuses = sourceRegistry.getStatuses();

  return (
    <Screen>
      <Text variant="title">Settings</Text>
      <Card>
        <Text variant="headline">Themes</Text>
        {Object.values(themePresets).map((theme) => (
          <Pressable key={theme.id} onPress={() => setTheme(theme.id)}>
            <Text>{theme.name}</Text>
            <Text muted>{theme.id === themeId ? "Active" : "Tap to apply"}</Text>
          </Pressable>
        ))}
      </Card>
      <Card>
        <Text variant="headline">Sources</Text>
        <Pressable onPress={() => router.push("/source-settings")}>
          <Text>Open source settings</Text>
        </Pressable>
        <View style={{ gap: 10 }}>
          {statuses.map((status) => (
            <ProviderStatusRow
              key={status.provider}
              provider={status.provider}
              enabled={providerStates[status.provider]}
              status={status.status}
              onToggle={() => toggleProvider(status.provider)}
            />
          ))}
        </View>
      </Card>
      <Card>
        <Text variant="headline">Taste Profile</Text>
        <Text muted>
          {tasteProfile.onboardingCompleted
            ? `Languages: ${tasteProfile.languages.length}, genres: ${tasteProfile.genres.length}, artists: ${tasteProfile.artists.length}.`
            : "Complete onboarding to seed your Discover recommendations."}
        </Text>
        <Pressable onPress={() => router.push("/onboarding?mode=edit")}>
          <Text>{tasteProfile.onboardingCompleted ? "Edit taste profile" : "Start taste onboarding"}</Text>
        </Pressable>
      </Card>
      <Card>
        <Text variant="headline">Private Use</Text>
        <Text muted>No backend, no analytics, no ads, no public account flow.</Text>
      </Card>
      <Card>
        <Text variant="headline">Personalization</Text>
        <Text muted>
          Continue listening and recently played stay first. Taste-driven recommendations blend with playback history over time.
        </Text>
      </Card>
      <Card>
        <Text variant="headline">Maintenance</Text>
        <Pressable onPress={clearRecentlyPlayed}>
          <Text>Clear recently played</Text>
        </Pressable>
      </Card>
    </Screen>
  );
}

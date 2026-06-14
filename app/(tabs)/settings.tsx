import { router } from "expo-router";
import { Pressable, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { ProviderStatusRow } from "@/components/ui/ProviderStatusRow";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { themePresets } from "@/constants/theme";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { useSettingsStore } from "@/modules/settings/settingsStore";

export default function SettingsScreen() {
  const themeId = useSettingsStore((state) => state.themeId);
  const setTheme = useSettingsStore((state) => state.setTheme);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const toggleProvider = useSettingsStore((state) => state.toggleProvider);
  const clearRecentlyPlayed = useLibraryStore((state) => state.clearRecentlyPlayed);
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
        <Text variant="headline">Private Use</Text>
        <Text muted>No backend, no analytics, no ads, no public account flow.</Text>
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

import { Pressable, StyleSheet, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { ProviderStatusRow } from "@/components/ui/ProviderStatusRow";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { themePresets } from "@/constants/theme";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { navigationService } from "@/services/navigationService";

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
        <View style={styles.themeGrid}>
          {Object.values(themePresets).map((preset) => {
            const active = preset.id === themeId;

            return (
              <Pressable
                key={preset.id}
                onPress={() => setTheme(preset.id)}
                style={[
                  styles.themePreview,
                  {
                    backgroundColor: preset.background,
                    borderColor: active ? preset.accent : preset.border,
                  },
                ]}
              >
                <View style={styles.themePreviewTop}>
                  <View style={styles.themePreviewCopy}>
                    <Text style={{ color: preset.text }}>{preset.name}</Text>
                    <Text muted style={{ color: active ? preset.accent : preset.textMuted }}>
                      {active ? "Active" : "Tap to apply"}
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.themeStatusDot,
                      {
                        backgroundColor: active ? preset.accent : preset.surfaceAlt,
                        borderColor: active ? preset.accent : preset.border,
                      },
                    ]}
                  />
                </View>

                <View style={[styles.themeStage, { backgroundColor: preset.card, borderColor: preset.border }]}>
                  <View style={styles.themeSwatchRow}>
                    <View style={[styles.themeSwatchLarge, { backgroundColor: preset.surface }]} />
                    <View style={styles.themeSwatchColumn}>
                      <View style={[styles.themeSwatchSmall, { backgroundColor: preset.surfaceAlt }]} />
                      <View style={[styles.themeSwatchSmall, { backgroundColor: preset.surface }]} />
                    </View>
                  </View>
                  <View style={styles.themeAccentRow}>
                    <View style={[styles.themeAccentChip, { backgroundColor: preset.accent }]} />
                    <View style={[styles.themeAccentChip, { backgroundColor: preset.accentAlt }]} />
                    <View style={[styles.themeAccentChipMuted, { backgroundColor: preset.surfaceAlt, borderColor: preset.border }]} />
                  </View>
                </View>
              </Pressable>
            );
          })}
        </View>
      </Card>
      <Card>
        <Text variant="headline">Sources</Text>
        <Pressable onPress={() => navigationService.push("/source-settings", "Opening sources…")} style={styles.settingsLink}>
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
            : "Set up your taste profile to personalize recommendations."}
        </Text>
        <Pressable onPress={() => navigationService.push("/onboarding?mode=edit", "Opening profile…")} style={styles.settingsLink}>
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
          Recommendations start with your taste profile, then adapt to what you actually play.
        </Text>
      </Card>
      <Card>
        <Text variant="headline">Maintenance</Text>
        <Pressable onPress={clearRecentlyPlayed} style={styles.settingsLink}>
          <Text>Clear recently played</Text>
        </Pressable>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  themeGrid: {
    gap: 14,
  },
  themePreview: {
    borderWidth: 1,
    borderRadius: 24,
    padding: 16,
    gap: 14,
  },
  themePreviewTop: {
    flexDirection: "row",
    alignItems: "flex-start",
    justifyContent: "space-between",
    gap: 12,
  },
  themePreviewCopy: {
    flex: 1,
    gap: 4,
  },
  themeStatusDot: {
    width: 14,
    height: 14,
    borderRadius: 999,
    borderWidth: 1,
    marginTop: 4,
  },
  themeStage: {
    borderWidth: 1,
    borderRadius: 18,
    padding: 12,
    gap: 12,
  },
  themeSwatchRow: {
    flexDirection: "row",
    gap: 10,
  },
  themeSwatchLarge: {
    flex: 1.2,
    height: 64,
    borderRadius: 14,
  },
  themeSwatchColumn: {
    flex: 1,
    gap: 10,
  },
  themeSwatchSmall: {
    height: 27,
    borderRadius: 12,
  },
  themeAccentRow: {
    flexDirection: "row",
    gap: 10,
  },
  themeAccentChip: {
    width: 34,
    height: 12,
    borderRadius: 999,
  },
  themeAccentChipMuted: {
    width: 34,
    height: 12,
    borderRadius: 999,
    borderWidth: 1,
  },
  settingsLink: {
    paddingVertical: 2,
  },
});

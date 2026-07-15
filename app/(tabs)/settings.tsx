import { useState, type ReactNode } from "react";
import { Pressable, StyleSheet, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { ProviderStatusRow } from "@/components/ui/ProviderStatusRow";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { themePresets } from "@/constants/theme";
import { useTheme } from "@/hooks/useTheme";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { navigationService } from "@/services/navigationService";
import type { ThemeId } from "@/constants/theme";
import type { MusicProvider } from "@/types/source";

type SectionId = "appearance" | "sources" | "profile" | "library";

type SettingsSectionProps = {
  id: SectionId;
  title: string;
  meta: string;
  icon: "settings" | "disc" | "person" | "playlist";
  expanded: boolean;
  onToggle: (id: SectionId) => void;
  children: ReactNode;
};

type QuickActionProps = {
  icon: "settings" | "tune" | "person";
  label: string;
  onPress: () => void;
};

type ThemeOptionProps = {
  id: ThemeId;
  active: boolean;
  onPress: (id: ThemeId) => void;
};

type HomeProviderOptionProps = {
  provider: MusicProvider;
  active: boolean;
  onPress: (provider: MusicProvider) => void;
};

const SettingsSection = ({ id, title, meta, icon, expanded, onToggle, children }: SettingsSectionProps) => {
  const theme = useTheme();

  return (
    <Card style={styles.sectionCard}>
      <Pressable onPress={() => onToggle(id)} style={styles.sectionHeader}>
        <View style={styles.sectionHeaderLeft}>
          <View style={[styles.sectionIcon, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <SymbolIcon name={icon} size={16} color={theme.accent} />
          </View>
          <View style={styles.sectionHeaderCopy}>
            <Text variant="headline">{title}</Text>
            <Text muted>{meta}</Text>
          </View>
        </View>
        <View
          style={[
            styles.chevronWrap,
            {
              backgroundColor: theme.surface,
              borderColor: theme.border,
              transform: [{ rotate: expanded ? "180deg" : "0deg" }],
            },
          ]}
        >
          <SymbolIcon name="down" size={16} color={theme.textMuted} />
        </View>
      </Pressable>
      {expanded ? <View style={styles.sectionBody}>{children}</View> : null}
    </Card>
  );
};

const QuickAction = ({ icon, label, onPress }: QuickActionProps) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.quickAction,
        {
          backgroundColor: theme.surface,
          borderColor: theme.border,
        },
      ]}
    >
      <View style={[styles.quickActionIcon, { backgroundColor: theme.card, borderColor: theme.border }]}>
        <SymbolIcon name={icon} size={18} color={theme.accent} />
      </View>
      <Text>{label}</Text>
      <SymbolIcon name="forward" size={16} color={theme.textMuted} />
    </Pressable>
  );
};

const ThemeOption = ({ id, active, onPress }: ThemeOptionProps) => {
  const preset = themePresets[id];

  return (
    <Pressable
      onPress={() => onPress(id)}
      style={[
        styles.themeOption,
        {
          backgroundColor: preset.card,
          borderColor: active ? preset.accent : preset.border,
        },
      ]}
    >
      <View style={styles.themeOptionTop}>
        <Text style={{ color: preset.text }}>{preset.name}</Text>
        <View
          style={[
            styles.themeCheck,
            {
              backgroundColor: active ? preset.accent : preset.surface,
              borderColor: active ? preset.accent : preset.border,
            },
          ]}
        >
          {active ? <SymbolIcon name="checkCircle" size={14} color={preset.card} /> : null}
        </View>
      </View>
      <View style={styles.themePreviewRow}>
        <View style={[styles.themePreviewLarge, { backgroundColor: preset.surface }]} />
        <View style={styles.themePreviewStack}>
          <View style={[styles.themePreviewSmall, { backgroundColor: preset.surfaceAlt }]} />
          <View style={[styles.themePreviewSmall, { backgroundColor: preset.accent }]} />
        </View>
      </View>
    </Pressable>
  );
};

const HomeProviderOption = ({ provider, active, onPress }: HomeProviderOptionProps) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={() => onPress(provider)}
      style={[
        styles.providerChip,
        {
          backgroundColor: active ? theme.accent : theme.surface,
          borderColor: active ? theme.accent : theme.border,
        },
      ]}
    >
      <Text style={{ color: active ? theme.background : theme.text }}>{providerLabels[provider]}</Text>
    </Pressable>
  );
};

const ActionRow = ({
  label,
  onPress,
  danger = false,
}: {
  label: string;
  onPress: () => void;
  danger?: boolean;
}) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.actionRow,
        {
          backgroundColor: theme.surface,
          borderColor: theme.border,
        },
      ]}
    >
      <Text style={danger ? { color: theme.danger } : undefined}>{label}</Text>
      <SymbolIcon name="forward" size={16} color={danger ? theme.danger : theme.textMuted} />
    </Pressable>
  );
};

export default function SettingsScreen() {
  const theme = useTheme();
  const themeId = useSettingsStore((state) => state.themeId);
  const setTheme = useSettingsStore((state) => state.setTheme);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const toggleProvider = useSettingsStore((state) => state.toggleProvider);
  const preferredHomeProvider = useSettingsStore((state) => state.preferredHomeProvider);
  const setPreferredHomeProvider = useSettingsStore((state) => state.setPreferredHomeProvider);
  const clearRecentlyPlayed = useLibraryStore((state) => state.clearRecentlyPlayed);
  const tasteProfile = useTasteProfileStore((state) => state.tasteProfile);
  const statuses = sourceRegistry.getStatuses();
  const [openSection, setOpenSection] = useState<SectionId | null>("appearance");

  const enabledStatuses = statuses.filter((status) => providerStates[status.provider]);
  const profileReady = tasteProfile.onboardingCompleted;
  const profileCount = tasteProfile.languages.length + tasteProfile.genres.length + tasteProfile.artists.length;

  const sourceMeta = enabledStatuses.length
    ? `${enabledStatuses.length} on · ${providerLabels[preferredHomeProvider]} first`
    : "All sources off";
  const profileMeta = profileReady ? `${profileCount} picks saved` : "Not set";

  const handleToggleSection = (id: SectionId) => {
    setOpenSection((current) => (current === id ? null : id));
  };

  return (
    <Screen contentContainerStyle={styles.screenContent}>
      <View style={styles.header}>
        <Text variant="title">Settings</Text>
        <View style={styles.statRow}>
          <View style={[styles.statPill, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text muted>{themePresets[themeId].name}</Text>
          </View>
          <View style={[styles.statPill, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text muted>{enabledStatuses.length} sources</Text>
          </View>
          <View style={[styles.statPill, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text muted>{profileReady ? "Profile ready" : "Profile off"}</Text>
          </View>
        </View>
      </View>

      <Card style={styles.quickCard}>
        <View style={styles.quickGrid}>
          <QuickAction label="Sources" icon="settings" onPress={() => navigationService.push("/source-settings", "Opening sources…")} />
          <QuickAction label="Player" icon="tune" onPress={() => navigationService.push("/player-settings", "Opening player settings…")} />
          <QuickAction label="Profile" icon="person" onPress={() => navigationService.push("/onboarding?mode=edit", "Opening profile…")} />
        </View>
      </Card>

      <SettingsSection
        id="appearance"
        title="Appearance"
        meta={themePresets[themeId].name}
        icon="settings"
        expanded={openSection === "appearance"}
        onToggle={handleToggleSection}
      >
        <View style={styles.themeGrid}>
          {(Object.keys(themePresets) as ThemeId[]).map((presetId) => (
            <ThemeOption key={presetId} id={presetId} active={presetId === themeId} onPress={setTheme} />
          ))}
        </View>
      </SettingsSection>

      <SettingsSection
        id="sources"
        title="Sources"
        meta={sourceMeta}
        icon="disc"
        expanded={openSection === "sources"}
        onToggle={handleToggleSection}
      >
        <ActionRow label="Open source settings" onPress={() => navigationService.push("/source-settings", "Opening sources…")} />
        <View style={styles.providerGroup}>
          <Text muted>Home opens with</Text>
          {enabledStatuses.length ? (
            <View style={styles.providerChipRow}>
              {enabledStatuses.map((status) => (
                <HomeProviderOption
                  key={status.provider}
                  provider={status.provider}
                  active={preferredHomeProvider === status.provider}
                  onPress={setPreferredHomeProvider}
                />
              ))}
            </View>
          ) : (
            <Text muted>Turn on a source to choose it.</Text>
          )}
        </View>
        <View style={styles.providerList}>
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
      </SettingsSection>

      <SettingsSection
        id="profile"
        title="Your Taste"
        meta={profileMeta}
        icon="person"
        expanded={openSection === "profile"}
        onToggle={handleToggleSection}
      >
        <View style={styles.profileGrid}>
          <View style={[styles.profileStat, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text variant="headline">{tasteProfile.languages.length}</Text>
            <Text muted>Languages</Text>
          </View>
          <View style={[styles.profileStat, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text variant="headline">{tasteProfile.genres.length}</Text>
            <Text muted>Genres</Text>
          </View>
          <View style={[styles.profileStat, { backgroundColor: theme.surface, borderColor: theme.border }]}>
            <Text variant="headline">{tasteProfile.artists.length}</Text>
            <Text muted>Artists</Text>
          </View>
        </View>
        <ActionRow
          label={profileReady ? "Edit your taste" : "Set up your taste"}
          onPress={() => navigationService.push("/onboarding?mode=edit", "Opening profile…")}
        />
      </SettingsSection>

      <SettingsSection
        id="library"
        title="Library"
        meta="Cleanup and playback"
        icon="playlist"
        expanded={openSection === "library"}
        onToggle={handleToggleSection}
      >
        <ActionRow label="Player settings" onPress={() => navigationService.push("/player-settings", "Opening player settings…")} />
        <ActionRow label="Clear recently played" onPress={clearRecentlyPlayed} danger />
      </SettingsSection>
    </Screen>
  );
}

const styles = StyleSheet.create({
  screenContent: {
    gap: 16,
  },
  header: {
    gap: 14,
  },
  statRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  statPill: {
    borderWidth: 1,
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  quickCard: {
    padding: 12,
  },
  quickGrid: {
    gap: 10,
  },
  quickAction: {
    borderWidth: 1,
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 14,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  quickActionIcon: {
    width: 34,
    height: 34,
    borderRadius: 17,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  sectionCard: {
    gap: 14,
  },
  sectionHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  sectionHeaderLeft: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    flex: 1,
  },
  sectionIcon: {
    width: 38,
    height: 38,
    borderRadius: 19,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  sectionHeaderCopy: {
    flex: 1,
    gap: 2,
  },
  chevronWrap: {
    width: 30,
    height: 30,
    borderRadius: 15,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  sectionBody: {
    gap: 14,
  },
  themeGrid: {
    gap: 10,
  },
  themeOption: {
    borderWidth: 1,
    borderRadius: 20,
    padding: 14,
    gap: 12,
  },
  themeOptionTop: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  themeCheck: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  themePreviewRow: {
    flexDirection: "row",
    gap: 10,
  },
  themePreviewLarge: {
    flex: 1.2,
    height: 46,
    borderRadius: 12,
  },
  themePreviewStack: {
    flex: 1,
    gap: 10,
  },
  themePreviewSmall: {
    flex: 1,
    borderRadius: 10,
  },
  providerGroup: {
    gap: 10,
  },
  providerChipRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  providerChip: {
    borderWidth: 1,
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 9,
  },
  providerList: {
    gap: 10,
  },
  profileGrid: {
    flexDirection: "row",
    gap: 10,
  },
  profileStat: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 18,
    paddingVertical: 14,
    paddingHorizontal: 12,
    gap: 4,
  },
  actionRow: {
    borderWidth: 1,
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
});

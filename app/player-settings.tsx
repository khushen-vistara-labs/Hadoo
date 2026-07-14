import { router } from "expo-router";
import { useState } from "react";
import { Pressable, StyleSheet, View } from "react-native";

import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import { useSettingsStore } from "@/modules/settings/settingsStore";

const qualities = ["low", "medium", "high"] as const;

export default function PlayerSettingsScreen() {
  const theme = useTheme();
  const audioQuality = useSettingsStore((state) => state.audioQuality);
  const setAudioQuality = useSettingsStore((state) => state.setAudioQuality);
  const [autoPlay, setAutoPlay] = useState(true);
  const [fallbackPlayback, setFallbackPlayback] = useState(true);
  const [crossfade, setCrossfade] = useState<0 | 2 | 4 | 6>(2);

  return (
    <Screen contentContainerStyle={{ paddingBottom: 32 }}>
      <View style={styles.header}>
        <Pressable
          hitSlop={10}
          onPress={() => router.back()}
          style={[styles.headerButton, { backgroundColor: theme.surfaceAlt, borderColor: theme.border }]}
        >
          <SymbolIcon name="navBack" size={20} color={theme.text} />
        </Pressable>
        <Text variant="headline">Player Settings</Text>
      </View>

      <View style={styles.section}>
        <Text muted variant="caption">
          Streaming
        </Text>
        <View style={[styles.card, { backgroundColor: theme.surface, borderColor: theme.border }]}>
          <View style={styles.rowTop}>
            <View style={[styles.iconBadge, { backgroundColor: theme.surfaceAlt }]}>
              <SymbolIcon name="play" size={18} color={theme.accent} />
            </View>
            <View style={styles.rowMeta}>
              <Text>Streaming Quality</Text>
              <Text muted>Global audio bitrate for online playback.</Text>
            </View>
          </View>
          <View style={styles.segmented}>
            {qualities.map((quality) => {
              const active = audioQuality === quality;
              return (
                <Pressable
                  key={quality}
                  onPress={() => setAudioQuality(quality)}
                  style={[
                    styles.segment,
                    {
                      backgroundColor: active ? theme.accent : theme.surfaceAlt,
                      borderColor: active ? theme.accent : theme.border,
                    },
                  ]}
                >
                  <Text style={{ color: active ? theme.background : theme.text }}>
                    {quality[0].toUpperCase() + quality.slice(1)}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text muted variant="caption">
          Playback
        </Text>
        <View style={[styles.card, { backgroundColor: theme.surface, borderColor: theme.border }]}>
          <SettingRow
            title="Auto Play"
            description="Enqueue similar songs when the queue ends."
            icon="play"
            value={autoPlay}
            onToggle={() => setAutoPlay((current) => !current)}
          />
          <Divider color={theme.border} />
          <SettingRow
            title="Auto Fallback Playback"
            description="Try a compatible resolver when a stream is missing."
            icon="search"
            value={fallbackPlayback}
            onToggle={() => setFallbackPlayback((current) => !current)}
          />
          <Divider color={theme.border} />
          <View style={styles.crossfadeBlock}>
            <View style={styles.rowTop}>
              <View style={[styles.iconBadge, { backgroundColor: theme.surfaceAlt }]}>
                <SymbolIcon name="shuffle" size={18} color={theme.accent} />
              </View>
              <View style={styles.rowMeta}>
                <Text>Crossfade</Text>
                <Text muted>{crossfade ? `${crossfade}s blend between tracks` : "Off"}</Text>
              </View>
              <Text style={{ color: theme.accent }}>{crossfade ? `${crossfade}s` : "Off"}</Text>
            </View>
            <View style={styles.segmented}>
              {[0, 2, 4, 6].map((value) => {
                const active = crossfade === value;
                return (
                  <Pressable
                    key={value}
                    onPress={() => setCrossfade(value as 0 | 2 | 4 | 6)}
                    style={[
                      styles.segment,
                      {
                        backgroundColor: active ? theme.accent : theme.surfaceAlt,
                        borderColor: active ? theme.accent : theme.border,
                      },
                    ]}
                  >
                    <Text style={{ color: active ? theme.background : theme.text }}>
                      {value ? `${value}s` : "Off"}
                    </Text>
                  </Pressable>
                );
              })}
            </View>
          </View>
          <Divider color={theme.border} />
          <Pressable style={styles.settingLink}>
            <View style={styles.rowTop}>
              <View style={[styles.iconBadge, { backgroundColor: theme.surfaceAlt }]}>
                <SymbolIcon name="equalizer" size={18} color={theme.accent} />
              </View>
              <View style={styles.rowMeta}>
                <Text>Equalizer</Text>
                <Text muted>Placeholder for future advanced tuning.</Text>
              </View>
              <SymbolIcon name="forward" size={18} color={theme.textMuted} />
            </View>
          </Pressable>
        </View>
      </View>
    </Screen>
  );
}

function Divider({ color }: { color: string }) {
  return <View style={{ height: 1, backgroundColor: color, opacity: 0.4 }} />;
}

function SettingRow({
  title,
  description,
  icon,
  value,
  onToggle,
}: {
  title: string;
  description: string;
  icon: "play" | "search";
  value: boolean;
  onToggle: () => void;
}) {
  const theme = useTheme();

  return (
    <View style={styles.rowTop}>
      <View style={[styles.iconBadge, { backgroundColor: theme.surfaceAlt }]}>
        <SymbolIcon name={icon} size={18} color={theme.accent} />
      </View>
      <View style={styles.rowMeta}>
        <Text>{title}</Text>
        <Text muted>{description}</Text>
      </View>
      <Pressable
        onPress={onToggle}
        style={[
          styles.toggle,
          {
            backgroundColor: value ? theme.accent : theme.surfaceAlt,
            borderColor: value ? theme.accent : theme.border,
          },
        ]}
      >
        <View
          style={[
            styles.toggleThumb,
            {
              backgroundColor: value ? theme.background : theme.textMuted,
              alignSelf: value ? "flex-end" : "flex-start",
            },
          ]}
        />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  headerButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  section: {
    gap: 12,
  },
  card: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 18,
    gap: 16,
  },
  rowTop: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  rowMeta: {
    flex: 1,
    gap: 2,
  },
  iconBadge: {
    width: 44,
    height: 44,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
  },
  segmented: {
    flexDirection: "row",
    gap: 10,
    flexWrap: "wrap",
  },
  segment: {
    minWidth: 76,
    borderRadius: 16,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    alignItems: "center",
  },
  toggle: {
    width: 54,
    borderRadius: 999,
    borderWidth: 1,
    padding: 4,
  },
  toggleThumb: {
    width: 20,
    height: 20,
    borderRadius: 999,
  },
  crossfadeBlock: {
    gap: 14,
  },
  settingLink: {
    gap: 12,
  },
});

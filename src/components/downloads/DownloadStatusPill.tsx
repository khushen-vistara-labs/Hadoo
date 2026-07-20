import { usePathname } from "expo-router";
import { Pressable, StyleSheet, View } from "react-native";

import { CircularDownloadIndicator } from "@/components/downloads/CircularDownloadIndicator";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { useDownloadStore } from "@/modules/downloads/downloadStore";
import { navigationService } from "@/services/navigationService";

export const DownloadStatusPill = () => {
  const pathname = usePathname();
  const theme = useTheme();
  const { isVisible: isMiniPlayerVisible, miniPlayerBottomOffset, miniPlayerHeight } = useMiniPlayerLayout();
  const tasksById = useDownloadStore((state) => state.tasks);
  const ongoingTasks = Object.values(tasksById).filter((task) => task.status !== "failed");

  if (
    !ongoingTasks.length ||
    pathname === "/downloads" ||
    pathname === "/now-playing" ||
    pathname === "/onboarding"
  ) {
    return null;
  }

  const downloadingTasks = ongoingTasks.filter((task) => task.status === "downloading");
  const resolvingTasks = ongoingTasks.filter((task) => task.status === "resolving");
  const queuedTasks = ongoingTasks.filter((task) => task.status === "queued");
  const primaryTask =
    downloadingTasks[0] ??
    ongoingTasks.find((task) => task.status === "resolving") ??
    queuedTasks[0];
  if (!primaryTask) {
    return null;
  }

  const activeCount = downloadingTasks.length + resolvingTasks.length;
  const statusText = activeCount
    ? `${activeCount} downloading${queuedTasks.length ? ` · ${queuedTasks.length} queued` : ""}`
    : queuedTasks.length
      ? `${queuedTasks.length} queued`
      : "Preparing download";
  const bottom = miniPlayerBottomOffset + (isMiniPlayerVisible ? miniPlayerHeight : 0) + 8;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`${statusText}. Open downloads.`}
      onPress={() => navigationService.push("/downloads", "Opening downloads…")}
      style={[styles.wrapper, { bottom }]}
    >
      <View style={[styles.pill, { backgroundColor: theme.surface, borderColor: theme.border }]}>
        <CircularDownloadIndicator task={primaryTask} size={36} />
        <View style={styles.copy}>
          <Text numberOfLines={1}>Downloads</Text>
          <Text muted variant="caption" numberOfLines={1}>
            {statusText}
          </Text>
        </View>
        <SymbolIcon name="forward" size={15} color={theme.textMuted} />
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: "absolute",
    left: 46,
    right: 46,
    zIndex: 30,
    elevation: 14,
  },
  pill: {
    minHeight: 52,
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 10,
    paddingVertical: 7,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    shadowColor: "#000",
    shadowOpacity: 0.24,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
  },
  copy: {
    flex: 1,
    gap: 1,
  },
});

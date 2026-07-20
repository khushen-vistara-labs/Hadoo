import { ActivityIndicator, StyleSheet, View } from "react-native";

import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import type { DownloadTask } from "@/modules/downloads/downloadStore";

const SEGMENT_COUNT = 16;

export const CircularDownloadIndicator = ({
  size = 44,
  task,
}: {
  size?: number;
  task: DownloadTask;
}) => {
  const theme = useTheme();
  const hasKnownProgress = task.status === "downloading" && Boolean(task.totalBytes);
  const percentage = hasKnownProgress ? Math.round(task.progress * 100) : 0;
  const activeSegments = hasKnownProgress
    ? Math.min(Math.max(Math.ceil(task.progress * SEGMENT_COUNT), 1), SEGMENT_COUNT)
    : 0;
  const segmentHeight = Math.max(Math.round(size * 0.13), 5);
  const segmentWidth = Math.max(Math.round(size * 0.045), 2);

  return (
    <View
      accessibilityLabel={
        task.status === "queued"
          ? `Queued, position ${task.queuePosition ?? 1}`
          : hasKnownProgress
            ? `${percentage} percent downloaded`
            : task.status
      }
      style={{ width: size, height: size }}
    >
      {Array.from({ length: SEGMENT_COUNT }, (_, index) => (
        <View
          key={index}
          pointerEvents="none"
          style={[
            styles.segmentOrbit,
            {
              transform: [{ rotate: `${(360 / SEGMENT_COUNT) * index}deg` }],
            },
          ]}
        >
          <View
            style={{
              alignSelf: "center",
              width: segmentWidth,
              height: segmentHeight,
              borderRadius: 999,
              backgroundColor: index < activeSegments ? theme.accent : `${theme.textMuted}3D`,
            }}
          />
        </View>
      ))}

      <View style={styles.indicatorCenter}>
        {task.status === "queued" ? (
          <Text muted style={[styles.centerText, { fontSize: size <= 36 ? 9 : 10 }]}>
            #{task.queuePosition ?? 1}
          </Text>
        ) : task.status === "failed" ? (
          <SymbolIcon name="refresh" size={size <= 36 ? 13 : 15} color={theme.textMuted} />
        ) : hasKnownProgress ? (
          <Text style={[styles.centerText, { color: theme.accent, fontSize: size <= 36 ? 8 : 9 }]}>
            {percentage}%
          </Text>
        ) : (
          <ActivityIndicator size="small" color={theme.accent} />
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  segmentOrbit: {
    ...StyleSheet.absoluteFillObject,
  },
  indicatorCenter: {
    ...StyleSheet.absoluteFillObject,
    alignItems: "center",
    justifyContent: "center",
  },
  centerText: {
    fontWeight: "700",
  },
});

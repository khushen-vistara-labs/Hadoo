import { useCallback, useMemo, useState } from "react";
import { LayoutChangeEvent, StyleSheet, View } from "react-native";

import { useTheme } from "@/hooks/useTheme";

type Props = {
  progress: number;
  interactive?: boolean;
  onScrubStart?: () => void;
  onScrubChange?: (progress: number) => void;
  onScrubComplete?: (progress: number) => void;
};

const clamp = (value: number) => Math.max(0, Math.min(value, 1));

export const ProgressBar = ({
  progress,
  interactive = false,
  onScrubStart,
  onScrubChange,
  onScrubComplete,
}: Props) => {
  const theme = useTheme();
  const [width, setWidth] = useState(0);
  const [dragProgress, setDragProgress] = useState<number | null>(null);
  const visualProgress = useMemo(
    () => (dragProgress == null ? clamp(progress) : dragProgress),
    [dragProgress, progress],
  );

  const updateDrag = useCallback(
    (locationX: number) => {
      if (!width) {
        return 0;
      }

      const next = clamp(locationX / width);
      setDragProgress(next);
      onScrubChange?.(next);
      return next;
    },
    [onScrubChange, width],
  );

  const handleLayout = useCallback((event: LayoutChangeEvent) => {
    setWidth(event.nativeEvent.layout.width);
  }, []);

  return (
    <View
      style={styles.wrapper}
      onLayout={handleLayout}
      onStartShouldSetResponder={() => interactive}
      onMoveShouldSetResponder={() => interactive}
      onResponderGrant={(event) => {
        if (!interactive) {
          return;
        }

        onScrubStart?.();
        updateDrag(event.nativeEvent.locationX);
      }}
      onResponderMove={(event) => {
        if (!interactive) {
          return;
        }

        updateDrag(event.nativeEvent.locationX);
      }}
      onResponderRelease={(event) => {
        if (!interactive) {
          return;
        }

        const next = updateDrag(event.nativeEvent.locationX);
        setDragProgress(null);
        onScrubComplete?.(next);
      }}
      onResponderTerminate={() => {
        setDragProgress(null);
      }}
    >
      <View style={[styles.track, { backgroundColor: theme.surfaceAlt }]}>
        <View
          style={[
            styles.fill,
            {
              backgroundColor: theme.accent,
              width: `${visualProgress * 100}%`,
            },
          ]}
        />
      </View>
      {interactive ? (
        <View
          pointerEvents="none"
          style={[
            styles.thumb,
            {
              backgroundColor: theme.text,
              borderColor: theme.background,
              left: `${visualProgress * 100}%`,
            },
          ]}
        />
      ) : null}
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    justifyContent: "center",
    minHeight: 28,
  },
  track: {
    height: 6,
    borderRadius: 999,
    overflow: "hidden",
  },
  fill: {
    height: "100%",
    borderRadius: 999,
  },
  thumb: {
    position: "absolute",
    width: 16,
    height: 16,
    borderRadius: 999,
    borderWidth: 3,
    marginLeft: -8,
  },
});

import { StyleSheet, View } from "react-native";

import { useTheme } from "@/hooks/useTheme";

type Props = {
  progress: number;
};

export const ProgressBar = ({ progress }: Props) => {
  const theme = useTheme();
  return (
    <View style={[styles.track, { backgroundColor: theme.surfaceAlt }]}>
      <View style={[styles.fill, { backgroundColor: theme.accent, width: `${Math.max(0, Math.min(progress, 1)) * 100}%` }]} />
    </View>
  );
};

const styles = StyleSheet.create({
  track: {
    height: 6,
    borderRadius: 999,
    overflow: "hidden",
  },
  fill: {
    height: "100%",
    borderRadius: 999,
  },
});

import { ActivityIndicator, StyleSheet, View } from "react-native";

import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import { useNavigationUiStore } from "@/store/navigationUiStore";

export const AppLoadingOverlay = () => {
  const theme = useTheme();
  const { isLoading: isNavigationLoading, label: navigationLabel } = useNavigationUiStore();
  const visible = isNavigationLoading;
  const label = navigationLabel ?? "Loading…";

  if (!visible) {
    return null;
  }

  return (
    <View pointerEvents="none" style={styles.overlay}>
      <View style={[styles.pill, { backgroundColor: `${theme.surface}F2`, borderColor: `${theme.border}CC` }]}>
        <ActivityIndicator size="small" color={theme.accent} />
        <Text>{label}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 24,
  },
  pill: {
    minWidth: 160,
    maxWidth: "100%",
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 10,
  },
});

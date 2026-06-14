import { StyleSheet, Switch, View } from "react-native";

import { providerLabels } from "@/constants/providers";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import type { MusicProvider, ProviderStatus } from "@/types/source";

type Props = {
  provider: MusicProvider;
  enabled: boolean;
  status: ProviderStatus;
  onToggle: () => void;
};

export const ProviderStatusRow = ({ provider, enabled, status, onToggle }: Props) => {
  const theme = useTheme();
  return (
    <View style={[styles.row, { borderColor: theme.border, backgroundColor: theme.surface }]}>
      <View style={styles.meta}>
        <Text>{providerLabels[provider]}</Text>
        <Text muted>{status.replaceAll("_", " ")}</Text>
      </View>
      <Switch value={enabled} onValueChange={onToggle} trackColor={{ true: theme.accent }} />
    </View>
  );
};

const styles = StyleSheet.create({
  row: {
    borderRadius: 18,
    borderWidth: 1,
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  meta: {
    gap: 4,
  },
});

import { Pressable, StyleSheet } from "react-native";

import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";

type Props = {
  label: string;
  active?: boolean;
  onPress: () => void;
};

export const Chip = ({ label, active = false, onPress }: Props) => {
  const theme = useTheme();
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.chip,
        {
          backgroundColor: active ? theme.accent : theme.surface,
          borderColor: active ? theme.accent : theme.border,
        },
      ]}
    >
      <Text muted={!active} style={{ color: active ? theme.background : theme.text }}>
        {label}
      </Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  chip: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    borderWidth: 1,
  },
});

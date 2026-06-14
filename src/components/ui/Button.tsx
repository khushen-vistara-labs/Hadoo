import { Pressable, StyleSheet, type PressableProps } from "react-native";

import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";

type Props = PressableProps & {
  label: string;
  tone?: "primary" | "secondary";
};

export const Button = ({ label, tone = "primary", style, ...props }: Props) => {
  const theme = useTheme();
  const primary = tone === "primary";
  return (
    <Pressable
      {...props}
      style={(state) => [
        styles.button,
        {
          backgroundColor: primary ? theme.accent : theme.surface,
          borderColor: primary ? theme.accent : theme.border,
        },
        typeof style === "function" ? style(state) : style,
      ]}
    >
      <Text style={{ color: primary ? theme.background : theme.text }}>{label}</Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: 16,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    alignItems: "center",
    justifyContent: "center",
  },
});

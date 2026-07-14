import type { PropsWithChildren } from "react";
import { Pressable, StyleSheet, View } from "react-native";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";

type Props = PropsWithChildren<{
  eyebrow: string;
  title: string;
  body: string;
  ctaLabel: string;
  onNext: () => void;
  onBack?: () => void;
  onSkip?: () => void;
  disableNext?: boolean;
}>;

export const OnboardingStepContainer = ({
  eyebrow,
  title,
  body,
  ctaLabel,
  onNext,
  onBack,
  onSkip,
  disableNext = false,
  children,
}: Props) => {
  const theme = useTheme();

  return (
    <Card style={[styles.card, { backgroundColor: theme.card }]}>
      <View style={styles.copy}>
        <Text variant="caption" style={{ color: theme.accent }}>
          {eyebrow}
        </Text>
        <Text variant="headline">{title}</Text>
        <Text muted>{body}</Text>
      </View>
      <View style={styles.body}>{children}</View>
      <View style={styles.footer}>
        {onBack ? <Button label="Back" tone="secondary" onPress={onBack} /> : <View style={styles.spacer} />}
        {onSkip ? (
          <Pressable onPress={onSkip} hitSlop={10}>
            <Text muted>Skip</Text>
          </Pressable>
        ) : (
          <View style={styles.spacer} />
        )}
        <Button label={ctaLabel} onPress={onNext} disabled={disableNext} style={disableNext ? styles.disabled : undefined} />
      </View>
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    gap: 20,
    padding: 20,
  },
  copy: {
    gap: 8,
  },
  body: {
    gap: 16,
  },
  footer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  spacer: {
    minWidth: 56,
  },
  disabled: {
    opacity: 0.5,
  },
});

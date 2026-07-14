import { StyleSheet, View } from "react-native";

import { ProgressBar } from "@/components/ui/ProgressBar";
import { Text } from "@/components/ui/Text";

export const ProgressHeader = ({
  currentStep,
  totalSteps,
  title,
  subtitle,
}: {
  currentStep: number;
  totalSteps: number;
  title: string;
  subtitle: string;
}) => (
  <View style={styles.container}>
    <View style={styles.copy}>
      <Text variant="caption">{`Step ${currentStep} of ${totalSteps}`}</Text>
      <Text variant="title">{title}</Text>
      <Text muted>{subtitle}</Text>
    </View>
    <ProgressBar progress={currentStep / totalSteps} />
  </View>
);

const styles = StyleSheet.create({
  container: {
    gap: 14,
  },
  copy: {
    gap: 6,
  },
});

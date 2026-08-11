import { StyleSheet, View } from "react-native";

import { ProgressBar } from "@/components/ui/ProgressBar";
import { Text } from "@/components/ui/Text";

export const ProgressHeader = ({
  currentStep,
  totalSteps,
}: {
  currentStep: number;
  totalSteps: number;
}) => (
  <View style={styles.container}>
    <Text muted variant="caption">{`Step ${currentStep} of ${totalSteps}`}</Text>
    <ProgressBar progress={currentStep / totalSteps} />
  </View>
);

const styles = StyleSheet.create({
  container: {
    gap: 8,
  },
});

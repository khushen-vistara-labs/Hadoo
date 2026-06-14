import { StyleSheet, View } from "react-native";

import { Text } from "@/components/ui/Text";

type Props = {
  title: string;
  subtitle?: string;
};

export const SectionHeader = ({ title, subtitle }: Props) => (
  <View style={styles.container}>
    <Text variant="headline">{title}</Text>
    {subtitle ? <Text muted>{subtitle}</Text> : null}
  </View>
);

const styles = StyleSheet.create({
  container: {
    gap: 4,
  },
});

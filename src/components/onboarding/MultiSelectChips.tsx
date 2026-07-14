import { StyleSheet, View } from "react-native";

import { Chip } from "@/components/ui/Chip";

export const MultiSelectChips = ({
  options,
  selected,
  onToggle,
}: {
  options: string[];
  selected: string[];
  onToggle: (value: string) => void;
}) => (
  <View style={styles.wrap}>
    {options.map((option) => (
      <Chip key={option} label={option} active={selected.includes(option)} onPress={() => onToggle(option)} />
    ))}
  </View>
);

const styles = StyleSheet.create({
  wrap: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
});

import { useEffect, useMemo, useState } from "react";
import { StyleSheet, View } from "react-native";
import { router } from "expo-router";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useSleepTimerStore } from "@/modules/player/sleepTimerStore";
import type { SleepTimerOption } from "@/types/lyrics";

const options: SleepTimerOption[] = ["5m", "10m", "15m", "30m", "45m", "60m", "end_of_track"];

const formatOptionLabel = (option: SleepTimerOption) =>
  option === "end_of_track" ? "End of track" : option;

export default function SleepTimerScreen() {
  const activeOption = useSleepTimerStore((state) => state.activeOption);
  const setTimer = useSleepTimerStore((state) => state.setTimer);
  const clearTimer = useSleepTimerStore((state) => state.clearTimer);
  const [draftOption, setDraftOption] = useState<SleepTimerOption | null>(activeOption);

  useEffect(() => {
    setDraftOption(activeOption);
  }, [activeOption]);

  const hasChanges = draftOption !== activeOption;
  const statusText = useMemo(() => {
    if (!activeOption) {
      return "No sleep timer is active.";
    }

    return `Active: ${formatOptionLabel(activeOption)}`;
  }, [activeOption]);

  return (
    <Screen>
      <Text variant="title">Sleep Timer</Text>
      <Card>
        <Text muted>{statusText}</Text>
        <Text muted>
          Pick a duration, then confirm with <Text>Set timer</Text>.
        </Text>
        <View style={styles.options}>
          {options.map((option) => (
            <Button
              key={option}
              label={formatOptionLabel(option)}
              tone={draftOption === option ? "primary" : "secondary"}
              onPress={() => setDraftOption(option)}
            />
          ))}
        </View>
        <View style={styles.actions}>
          <Button
            label="Cancel timer"
            tone="secondary"
            onPress={() => {
              clearTimer();
              setDraftOption(null);
              router.back();
            }}
            style={styles.secondaryAction}
          />
          <Button
            label="Set timer"
            onPress={() => {
              if (!draftOption) {
                return;
              }

              setTimer(draftOption);
              router.back();
            }}
            disabled={!draftOption || !hasChanges}
            style={styles.primaryAction}
          />
        </View>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  options: {
    gap: 10,
  },
  actions: {
    flexDirection: "row",
    gap: 10,
  },
  secondaryAction: {
    flex: 1,
  },
  primaryAction: {
    flex: 1,
  },
});

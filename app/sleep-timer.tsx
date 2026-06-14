import { useState } from "react";
import { View } from "react-native";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import type { SleepTimerOption } from "@/types/lyrics";

const options: SleepTimerOption[] = ["5m", "10m", "15m", "30m", "45m", "60m", "end_of_track"];

export default function SleepTimerScreen() {
  const [active, setActive] = useState<SleepTimerOption | null>(null);

  return (
    <Screen>
      <Text variant="title">Sleep Timer</Text>
      <Card>
        <Text muted>{active ? `Active: ${active.replace("_", " ")}` : "No active timer."}</Text>
        <View style={{ gap: 10 }}>
          {options.map((option) => (
            <Button key={option} label={option.replace("_", " ")} tone={active === option ? "primary" : "secondary"} onPress={() => setActive(option)} />
          ))}
          <Button label="Cancel timer" tone="secondary" onPress={() => setActive(null)} />
        </View>
      </Card>
    </Screen>
  );
}

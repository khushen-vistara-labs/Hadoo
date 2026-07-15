import { Card } from "@/components/ui/Card";
import { ProviderStatusRow } from "@/components/ui/ProviderStatusRow";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useSettingsStore } from "@/modules/settings/settingsStore";

export default function SourceSettingsScreen() {
  const statuses = sourceRegistry.getStatuses();
  const providerStates = useSettingsStore((state) => state.providerStates);
  const toggleProvider = useSettingsStore((state) => state.toggleProvider);

  return (
    <Screen>
      <Text variant="title">Source Settings</Text>
      <Card>
        <Text muted>Experimental providers stay isolated so they can fail cleanly. Playback falls back through YouTube Music, then YouTube, when a stream-capable source cannot resolve.</Text>
      </Card>
      {statuses.map((status) => (
        <ProviderStatusRow
          key={status.provider}
          provider={status.provider}
          enabled={providerStates[status.provider]}
          status={status.status}
          onToggle={() => toggleProvider(status.provider)}
        />
      ))}
    </Screen>
  );
}

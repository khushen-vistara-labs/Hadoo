import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { TrackRow } from "@/components/player/TrackRow";
import { usePlayer } from "@/hooks/usePlayer";
import { playerService } from "@/modules/player/playerService";

export default function QueueScreen() {
  const player = usePlayer();

  return (
    <Screen contentContainerStyle={{ paddingBottom: 132 }}>
      <Text variant="title">Queue</Text>
      {player.queue.map((track) => (
        <TrackRow key={track.id} track={track} onPress={() => playerService.playTrack(track, player.queue)} />
      ))}
    </Screen>
  );
}

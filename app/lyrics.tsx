import { useQuery } from "@tanstack/react-query";

import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { usePlayer } from "@/hooks/usePlayer";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";

export default function LyricsScreen() {
  const currentTrack = usePlayer().currentTrack;
  const lyricsQuery = useQuery({
    queryKey: ["lyrics", currentTrack?.id],
    queryFn: () => (currentTrack ? sourceRegistry.getLyrics(currentTrack) : []),
    enabled: Boolean(currentTrack),
  });

  return (
    <Screen>
      <Text variant="title">Lyrics</Text>
      <Text muted>Lyrics for the current track.</Text>
      <Card>
        {lyricsQuery.data?.length ? (
          lyricsQuery.data.map((line, index) => (
            <Text key={`${line.time ?? index}-${line.text}`} muted={index !== 0}>
              {line.text}
            </Text>
          ))
        ) : (
          <Text muted>Pick a track to view lyrics.</Text>
        )}
      </Card>
    </Screen>
  );
}

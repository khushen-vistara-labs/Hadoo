import { useQuery } from "@tanstack/react-query";
import { LinearGradient } from "expo-linear-gradient";
import { useLocalSearchParams } from "expo-router";
import { useEffect, useMemo, useState } from "react";
import { ScrollView, StyleSheet, View } from "react-native";

import { MultiSelectChips } from "@/components/onboarding/MultiSelectChips";
import { OnboardingStepContainer } from "@/components/onboarding/OnboardingStepContainer";
import { ProgressHeader } from "@/components/onboarding/ProgressHeader";
import { SelectableArtistChips } from "@/components/onboarding/SelectableArtistChips";
import { Button } from "@/components/ui/Button";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { useTasteProfileStore } from "@/modules/recommendations/tasteProfileStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { navigationService } from "@/services/navigationService";
import { useSettingsStore } from "@/modules/settings/settingsStore";

const LANGUAGE_OPTIONS = [
  "Hindi",
  "English",
  "Kannada",
  "Tamil",
  "Telugu",
  "Malayalam",
  "Punjabi",
  "Marathi",
  "Gujarati",
  "Bengali",
  "Odia",
  "Assamese",
  "Urdu",
  "Konkani",
  "Tulu",
  "Sanskrit",
  "Haryanvi",
  "Bhojpuri",
  "Rajasthani",
  "Sindhi",
  "Kashmiri",
  "Dogri",
  "Manipuri",
  "Nepali",
  "Sinhala",
  "Arabic",
  "Spanish",
  "French",
  "German",
  "Japanese",
  "Korean",
  "Mandarin",
];
const GENRE_OPTIONS = ["Pop", "Hip-Hop", "Indie", "Electronic", "Bollywood", "Devotional", "Romance", "Lo-fi", "Classical", "Rock", "Instrumental"];
const MOOD_OPTIONS = ["Focus", "Late Night", "Workout", "Chill", "Road Trip", "Soulful"];
const ERA_OPTIONS = ["90s", "2000s", "2010s", "Fresh Releases", "Golden Classics"];

const toggleValue = (current: string[], value: string) =>
  current.includes(value) ? current.filter((entry) => entry !== value) : [...current, value];

const normalizeArtist = (value: string) =>
  value
    .trim()
    .replace(/\s+/g, " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase());

export default function OnboardingScreen() {
  const theme = useTheme();
  const { mode } = useLocalSearchParams<{ mode?: string }>();
  const preferredHomeProvider = useSettingsStore((state) => state.preferredHomeProvider);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const tasteProfile = useTasteProfileStore((state) => state.tasteProfile);
  const completeOnboarding = useTasteProfileStore((state) => state.completeOnboarding);
  const [stepIndex, setStepIndex] = useState(0);
  const [languages, setLanguages] = useState<string[]>(tasteProfile.languages);
  const [genres, setGenres] = useState<string[]>(tasteProfile.genres);
  const [artists, setArtists] = useState<string[]>(tasteProfile.artists);
  const [moods, setMoods] = useState<string[]>(tasteProfile.moods);
  const [eras, setEras] = useState<string[]>(tasteProfile.eras);
  const [artistQuery, setArtistQuery] = useState("");
  const [debouncedArtistQuery, setDebouncedArtistQuery] = useState("");
  const isEditMode = mode === "edit";
  const activeArtistProvider = providerStates[preferredHomeProvider] ? preferredHomeProvider : "all";
  const { contentBottomSpacing } = useMiniPlayerLayout();

  useEffect(() => {
    const timeout = setTimeout(() => {
      setDebouncedArtistQuery(artistQuery.trim());
    }, 250);

    return () => clearTimeout(timeout);
  }, [artistQuery]);

  const artistSearch = useQuery({
    queryKey: ["artist-onboarding-search", activeArtistProvider, debouncedArtistQuery],
    enabled: debouncedArtistQuery.length >= 2,
    staleTime: 5 * 60 * 1000,
    queryFn: async () =>
      (await sourceRegistry.searchArtists(debouncedArtistQuery, activeArtistProvider)).slice(0, 10),
  });

  const artistSuggestions = useMemo(() => {
    const normalizedSelection = new Set(artists.map((artist) => artist.toLowerCase()));
    return (artistSearch.data ?? []).filter((artist) => !normalizedSelection.has(artist.toLowerCase()));
  }, [artistSearch.data, artists]);

  const stepCount = 5;

  const steps = [
    {
      content: (
        <OnboardingStepContainer
          title="What languages do you listen to?"
          body="Pick at least one."
          ctaLabel="Continue"
          onNext={() => setStepIndex(1)}
          disableNext={!languages.length}
        >
          <MultiSelectChips
            options={LANGUAGE_OPTIONS}
            selected={languages}
            onToggle={(value) => setLanguages((current) => toggleValue(current, value))}
          />
        </OnboardingStepContainer>
      ),
    },
    {
      content: (
        <OnboardingStepContainer
          title="What kind of music do you like?"
          body="Choose a few genres."
          ctaLabel="Continue"
          onBack={() => setStepIndex(0)}
          onNext={() => setStepIndex(2)}
          disableNext={!genres.length}
        >
          <MultiSelectChips
            options={GENRE_OPTIONS}
            selected={genres}
            onToggle={(value) => setGenres((current) => toggleValue(current, value))}
          />
        </OnboardingStepContainer>
      ),
    },
    {
      content: (
        <OnboardingStepContainer
          title="Who are your favorite artists?"
          body="Search and select any you love. This step is optional."
          ctaLabel="Continue"
          onBack={() => setStepIndex(1)}
          onNext={() => setStepIndex(3)}
          onSkip={() => setStepIndex(3)}
        >
          <SelectableArtistChips
            selected={artists}
            suggestions={artistSuggestions}
            query={artistQuery}
            onQueryChange={setArtistQuery}
            onToggleArtist={(artist) => setArtists((current) => toggleValue(current, artist))}
            onAddTypedArtist={() => {
              const next = normalizeArtist(artistQuery);
              if (!next || artists.some((artist) => artist.toLowerCase() === next.toLowerCase())) {
                return;
              }
              setArtists((current) => [...current, next]);
              setArtistQuery("");
            }}
            loading={artistSearch.isLoading}
            providerUnavailable={artistSearch.isError}
          />
        </OnboardingStepContainer>
      ),
    },
    {
      content: (
        <OnboardingStepContainer
          title="What fits your mood?"
          body="Choose any moods or eras you enjoy. This step is optional."
          ctaLabel="Continue"
          onBack={() => setStepIndex(2)}
          onNext={() => setStepIndex(4)}
          onSkip={() => setStepIndex(4)}
        >
          <View style={styles.optionalGroup}>
            <Text muted>Moods</Text>
            <MultiSelectChips
              options={MOOD_OPTIONS}
              selected={moods}
              onToggle={(value) => setMoods((current) => toggleValue(current, value))}
            />
          </View>
          <View style={styles.optionalGroup}>
            <Text muted>Eras</Text>
            <MultiSelectChips
              options={ERA_OPTIONS}
              selected={eras}
              onToggle={(value) => setEras((current) => toggleValue(current, value))}
            />
          </View>
        </OnboardingStepContainer>
      ),
    },
    {
      content: (
        <OnboardingStepContainer
          title="Looks good?"
          body="You can change these choices anytime in Settings."
          ctaLabel={isEditMode ? "Save" : "Start listening"}
          onBack={() => setStepIndex(3)}
          onNext={() => {
            completeOnboarding({
              languages,
              genres,
              artists,
              moods,
              eras,
            });
            navigationService.replace(isEditMode ? "/settings" : "/", isEditMode ? "Saving profile…" : "Opening Discover…");
          }}
        >
          <LinearGradient
            colors={[theme.surfaceAlt, theme.surface, theme.background]}
            style={[styles.summaryHero, { borderColor: theme.border }]}
          >
            <Text variant="headline">Your picks</Text>
            <View style={styles.summaryBlock}>
              <Text muted>Languages</Text>
              <Text>{languages.join(" • ")}</Text>
            </View>
            <View style={styles.summaryBlock}>
              <Text muted>Genres</Text>
              <Text>{genres.join(" • ")}</Text>
            </View>
            {artists.length ? (
              <View style={styles.summaryBlock}>
                <Text muted>Artists</Text>
                <Text numberOfLines={2}>{artists.join(" • ")}</Text>
              </View>
            ) : null}
            {moods.length || eras.length ? (
              <View style={styles.summaryBlock}>
                <Text muted>Moods and eras</Text>
                <Text>{[...moods, ...eras].join(" • ")}</Text>
              </View>
            ) : null}
          </LinearGradient>
        </OnboardingStepContainer>
      ),
    },
  ];

  return (
    <Screen scroll={false}>
      <ScrollView
        contentContainerStyle={[styles.content, { paddingBottom: styles.content.paddingBottom + contentBottomSpacing }]}
        showsVerticalScrollIndicator={false}
      >
        {isEditMode ? (
          <View style={styles.header}>
            <Text variant="title">Edit taste</Text>
            <Button label="Close" tone="secondary" onPress={() => navigationService.replace("/settings", "Opening settings…")} />
          </View>
        ) : null}

        <ProgressHeader currentStep={stepIndex + 1} totalSteps={stepCount} />

        {steps[stepIndex].content}
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  content: {
    padding: 20,
    paddingBottom: 40,
    gap: 22,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  optionalGroup: {
    gap: 10,
  },
  summaryHero: {
    borderRadius: 20,
    borderWidth: 1,
    padding: 18,
    gap: 14,
  },
  summaryBlock: {
    gap: 4,
  },
});

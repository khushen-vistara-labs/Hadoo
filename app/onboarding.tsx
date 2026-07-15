import { useQuery } from "@tanstack/react-query";
import { LinearGradient } from "expo-linear-gradient";
import { router, useLocalSearchParams } from "expo-router";
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
  "Instrumental",
];
const GENRE_OPTIONS = ["Pop", "Hip-Hop", "Indie", "Electronic", "Bollywood", "Devotional", "Romance", "Lo-fi", "Classical", "Rock"];
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
    queryFn: async () => {
      const tracks = await sourceRegistry.search(debouncedArtistQuery, activeArtistProvider);
      return [...new Set(tracks.flatMap((track) => track.artists?.length ? track.artists : [track.artist]).filter(Boolean))].slice(0, 10);
    },
  });

  const artistSuggestions = useMemo(() => {
    const normalizedSelection = new Set(artists.map((artist) => artist.toLowerCase()));
    return (artistSearch.data ?? []).filter((artist) => !normalizedSelection.has(artist.toLowerCase()));
  }, [artistSearch.data, artists]);

  const stepCount = 5;

  const steps = [
    {
      title: "Pick the languages you reach for",
      subtitle: "This helps shape your first shelves before playback history exists.",
      content: (
        <OnboardingStepContainer
          eyebrow="Taste Profile"
          title="Languages first"
          body="Choose the languages you want your home feed to lean on."
          ctaLabel="Next"
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
      title: "Shape the sound",
      subtitle: "Genres and categories give the recommendation layer something concrete to rank against.",
      content: (
        <OnboardingStepContainer
          eyebrow="Taste Profile"
          title="What should dominate?"
          body="Pick a few genres or categories. This becomes the first signal for discovery."
          ctaLabel="Next"
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
      title: "Name the artists that matter",
      subtitle: "Artist picks are optional, but they give the home feed a much stronger opening signal.",
      content: (
        <OnboardingStepContainer
          eyebrow="Artist Seeds"
          title="Who should anchor the feed?"
          body="Search your active provider when possible, or type artist names directly."
          ctaLabel="Next"
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
      title: "Set the vibe",
      subtitle: "Mood and era are optional soft signals. They help ranking without hard-filtering the homepage.",
      content: (
        <OnboardingStepContainer
          eyebrow="Optional Layers"
          title="Mood and era"
          body="These tags help the app nudge provider shelves toward the feeling you want."
          ctaLabel="Next"
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
      title: "Build your home feed",
      subtitle: "These picks shape your first recommendations, then give way to real listening over time.",
      content: (
        <OnboardingStepContainer
          eyebrow="Ready"
          title="Building your home feed"
          body="This profile stays on-device and seeds recommendations until your listening history becomes strong enough to take over."
          ctaLabel={isEditMode ? "Save taste profile" : "Enter Discover"}
          onBack={() => setStepIndex(3)}
          onNext={() => {
            completeOnboarding({
              languages,
              genres,
              artists,
              moods,
              eras,
            });
            router.replace(isEditMode ? "/settings" : "/");
          }}
        >
          <LinearGradient
            colors={[theme.surfaceAlt, theme.surface, theme.background]}
            style={[styles.summaryHero, { borderColor: theme.border }]}
          >
            <Text variant="headline">Personalization summary</Text>
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
                <Text muted>Vibe</Text>
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
        <View style={styles.header}>
          <View style={styles.headerCopy}>
            <Text variant="title">{isEditMode ? "Edit Taste Profile" : "Make Discover yours"}</Text>
            <Text muted>
              {isEditMode
                ? "Update the signals that shape your recommendations."
                : "A short setup to make Discover feel personal from the start."}
            </Text>
          </View>
          {isEditMode ? <Button label="Close" tone="secondary" onPress={() => router.replace("/settings")} /> : null}
        </View>

        <ProgressHeader
          currentStep={stepIndex + 1}
          totalSteps={stepCount}
          title={steps[stepIndex].title}
          subtitle={steps[stepIndex].subtitle}
        />

        {steps[stepIndex].content}

        {!isEditMode && stepIndex === 0 ? <Text muted style={styles.secondaryLink}>You can change all of this later.</Text> : null}
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
    gap: 16,
  },
  headerCopy: {
    gap: 8,
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
  secondaryLink: {
    alignSelf: "center",
  },
});

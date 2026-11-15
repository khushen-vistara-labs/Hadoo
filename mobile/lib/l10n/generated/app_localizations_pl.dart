// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get aLittleRecordOfWhatStayed => 'Mały zapis tego, co się powtarzało.';

  @override
  String get aNewerFlickBuildIsOn =>
      'Nowsza wersja Hadoo jest dostępna w Sklepie Play.';

  @override
  String get aPlaylistWithThisNameAlready =>
      'Lista odtwarzania o tej nazwie już istnieje';

  @override
  String get aSmoothContinuousWaveAcrossFrequencies =>
      'Gładka fala ciągła na różnych częstotliwościach';

  @override
  String get aSongWithALongTitle => 'Piosenka z długim tytułem do podglądu';

  @override
  String get aTighterMixOfFavoritesAnd =>
      'Bardziej rygorystyczna mieszanka ulubionych utworów i utworów, do których ciągle powracasz.';

  @override
  String get aWeekAndCountingYourDedication =>
      'Tydzień trwa – widać Twoje zaangażowanie.';

  @override
  String get aaudio => 'AAudio';

  @override
  String get aaudioAndroid81 => 'AAudio (Android 8.1 lub nowszy)';

  @override
  String get aaudioWithOpenslEsFallbackDefault =>
      'AAudio z rezerwą OpenSL ES (domyślnie)';

  @override
  String get about => 'Informacje';

  @override
  String get aboutThisAlbum => 'O tym albumie';

  @override
  String get absoluteVolumeSync => 'Absolutna synchronizacja głośności';

  @override
  String get accentColor => 'Kolor akcentu';

  @override
  String get accuraterip => 'Dokładny rip';

  @override
  String achieved(Object arg1) {
    return 'Osiągnięto $arg1';
  }

  @override
  String get achievementUnlocked => 'OSIĄGNIĘCIA ODBLOKOWANE';

  @override
  String get activateFallback => 'Aktywuj rezerwę';

  @override
  String get active => 'Aktywny';

  @override
  String activeBands(Object activeCount) {
    return 'Pasma aktywne $activeCount';
  }

  @override
  String get activeDays => 'Aktywne dni';

  @override
  String get add => 'Dodaj';

  @override
  String get addAMusicFolderInSettings =>
      'Dodaj folder muzyczny w Ustawieniach';

  @override
  String get addANextTrackButton => 'Dodaj przycisk następnego utworu';

  @override
  String get addAPreviousTrackButton => 'Dodaj przycisk poprzedniego utworu';

  @override
  String get addAtLeastOneLyricLine =>
      'Najpierw dodaj co najmniej jedną linijkę tekstu.';

  @override
  String get addDescription => 'Dodaj opis';

  @override
  String get addDescription2 => 'Dodaj opis';

  @override
  String get addMusicFoldersInSettings =>
      'Dodaj foldery muzyczne w Ustawieniach';

  @override
  String get addMusicWithAlbumTagsTo =>
      'Dodaj muzykę ze znacznikami albumów, aby zobaczyć je tutaj';

  @override
  String get addMusicWithArtistTagsTo =>
      'Dodaj muzykę ze znacznikami wykonawców, aby zobaczyć ją tutaj';

  @override
  String get addServer => 'Dodaj serwer';

  @override
  String get addSongsFromThePlayerMenu => 'Dodaj utwory z menu odtwarzacza';

  @override
  String get addSongsFromThePlayerOr =>
      'Dodaj utwory z menu odtwarzacza lub akcji utworów.';

  @override
  String addSongsToPlaylist(Object arg1) {
    return 'Dodaj utwory $arg1 do listy odtwarzania';
  }

  @override
  String addSongsToPlaylist2(Object arg1) {
    return 'Dodaj utwory $arg1 do listy odtwarzania';
  }

  @override
  String get addToFavorites => 'Dodaj do ulubionych';

  @override
  String get addToFavorites2 => 'Dodaj do ulubionych';

  @override
  String get addToPlaylist => 'Dodaj do playlisty';

  @override
  String get addToPlaylist2 => 'Dodaj do playlisty';

  @override
  String get addToQueue => 'Dodaj do kolejki';

  @override
  String get addToQueue2 => 'Dodaj do kolejki';

  @override
  String addedSongsTo(Object arg1, Object arg2) {
    return 'Dodano utwory $arg1 do „$arg2”';
  }

  @override
  String addedSongsTo2(Object arg1, Object playlistName) {
    return 'Dodano utwory $arg1 do $playlistName';
  }

  @override
  String addedSongsToFavorites(Object arg1) {
    return 'Dodano utwory $arg1 do ulubionych';
  }

  @override
  String addedSongsToFavorites3(Object arg1) {
    return 'Dodano utwory $arg1 do ulubionych';
  }

  @override
  String addedSongsToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano utwory $count do kolejki',
      one: 'Dodano do kolejki',
    );
    return '$_temp0';
  }

  @override
  String addedTo(Object arg1) {
    return 'Dodano do $arg1';
  }

  @override
  String addedTo2(Object arg1) {
    return 'Dodano do „$arg1”';
  }

  @override
  String get addedToFavorites => 'Dodano do ulubionych';

  @override
  String addedToFavorites2(Object arg1) {
    return 'Dodano „$arg1” do ulubionych';
  }

  @override
  String get addsPreDriveAndCatchesPeaks =>
      'Dodaje napęd wstępny i wychwytuje szczyty w stosunku do ostatecznego pułapu wyjściowego.';

  @override
  String get adjustMetadataTextSizeInArtwork =>
      'Dostosuj rozmiar tekstu metadanych w trybie karty graficznej';

  @override
  String get adjustMetadataTextSizeInImmersive =>
      'Dostosuj rozmiar tekstu metadanych w trybie immersyjnym';

  @override
  String get adjustTheMiniPlayerSurface =>
      'Dostosuj powierzchnię miniodtwarzacza';

  @override
  String get advanceToARandomCategory => 'Przejdź do losowej kategorii';

  @override
  String get advanceToTheNextCategoryAlphabetically =>
      'Przejdź do następnej kategorii alfabetycznie';

  @override
  String get advanceToTheNextMostRecently =>
      'Przejdź do kolejnej ostatnio dodanej kategorii';

  @override
  String get advanced => 'Zaawansowany';

  @override
  String get advancedMode => 'Tryb zaawansowany';

  @override
  String get afterHours => 'Po godzinach';

  @override
  String get afterScanningMatchFilesWithMissing =>
      'Po zeskanowaniu dopasuj pliki z brakującymi znacznikami do Apple Music. Tylko pewne dopasowania są stosowane automatycznie.';

  @override
  String get air => 'Powietrze';

  @override
  String get alacAudio => 'ALAC Audio';

  @override
  String alacBit(Object arg1) {
    return 'ALAC $arg1-bit';
  }

  @override
  String get album => 'Album';

  @override
  String get albumArt => 'Grafika albumu';

  @override
  String get albumArt2 => 'Okładka albumu';

  @override
  String get albumArtist => 'Wykonawca albumu';

  @override
  String get albumArtists => 'Artyści albumowi';

  @override
  String get albumArtwork => 'Grafika albumu';

  @override
  String get albumColors => 'Kolory albumu';

  @override
  String get albumCount => 'Liczba albumów';

  @override
  String get albumLimit => 'LIMIT ALBUMU';

  @override
  String get albumName => 'Nazwa albumu';

  @override
  String get albumOptions => 'Opcje albumu';

  @override
  String get albums => 'Albumy';

  @override
  String albums2(Object arg1) {
    return 'albumy $arg1';
  }

  @override
  String albums3(Object _totalAlbums) {
    return 'albumy $_totalAlbums';
  }

  @override
  String get albumsShownPerPage => 'Albumy wyświetlane na stronie';

  @override
  String albumsSongs(Object arg1, Object arg2) {
    return 'Albumy $arg1 • Utwory $arg2';
  }

  @override
  String get all => 'Wszyscy';

  @override
  String get allArtists => 'Wszyscy wykonawcy';

  @override
  String get allClearNoDuplicates => 'Wszystko jasne – żadnych duplikatów';

  @override
  String get allFormats => 'Wszystkie formaty';

  @override
  String get allFrequenciesEqually => 'Wszystkie częstotliwości jednakowo';

  @override
  String get allPass => 'Wszystkie przepustki';

  @override
  String get allResultsAreHiddenByActive =>
      'Wszystkie wyniki są ukryte przez aktywne filtry.';

  @override
  String get allSongs => 'Wszystkie utwory';

  @override
  String get allWordsStamped => 'Wszystkie słowa stemplowane';

  @override
  String get allowed => 'Dozwolone';

  @override
  String get alphabetical => 'Alfabetycznie';

  @override
  String get alsoRespectsYourSystemTextSize =>
      'Respektuje także rozmiar tekstu systemowego';

  @override
  String alt(Object arg1) {
    return 'Alternatywnie $arg1';
  }

  @override
  String get amber => 'Bursztyn';

  @override
  String get andArtwork => ' i dzieła sztuki';

  @override
  String andMoreInRotation(Object arg1) {
    return '$arg1 i więcej w rotacji';
  }

  @override
  String get android => 'Androida';

  @override
  String get androidAudioApi => 'Interfejs audio Androida';

  @override
  String get androidBlockedWritingToThisFile =>
      'Android zablokował zapis do tego pliku. Usuń i ponownie dodaj folder w Ustawieniach, aby przyznać uprawnienia do edycji, a następnie spróbuj ponownie.';

  @override
  String get androidDeveloperOptionsTheReliableWay =>
      'Opcje programistyczne Androida — niezawodny sposób na zmianę kodeka (wymuszanie w aplikacji wykorzystuje ukryty systemowy interfejs API, który jest blokowany w standardowym systemie Android)';

  @override
  String get androidDockRoute => 'Trasa dokowania Androida';

  @override
  String get androidManagedRustPlaybackPathUsing =>
      'Ścieżka odtwarzania Rusta zarządzana przez Androida przy użyciu natywnego backendu oboju.';

  @override
  String get androidUsbRoute => 'Trasa USB dla Androida';

  @override
  String get animationStyle => 'Styl animacji';

  @override
  String get apiKey => 'Klucz API';

  @override
  String get appTitle => 'Hadoo';

  @override
  String get appearance => 'Wygląd';

  @override
  String get appleMusicDataUnavailable => 'Dane Apple Music są niedostępne';

  @override
  String get appleMusicDataUpdated => 'Zaktualizowano dane Apple Music';

  @override
  String get appleMusicLookupFailedCheckYour =>
      'Wyszukiwanie Apple Music nie powiodło się. Sprawdź swoje połączenie.';

  @override
  String appliedAutoeqFor(Object arg1) {
    return 'Zastosowano AutoEQ w $arg1';
  }

  @override
  String get apply => 'Zastosuj';

  @override
  String apply2(Object arg1) {
    return 'Zastosuj $arg1';
  }

  @override
  String get applySelected => 'Zastosuj wybrane';

  @override
  String applyTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return 'Zastosuj do $_temp0';
  }

  @override
  String get applyingNewAudioEngine => 'Stosowanie nowego silnika audio…';

  @override
  String get apr => 'kwiecień';

  @override
  String get aptxAdaptive => 'aptX Adaptacyjny';

  @override
  String get aptxHd => 'aptX HD';

  @override
  String get areYouSureYouWantTo => 'Czy na pewno chcesz usunąć tę playlistę?';

  @override
  String get areYouSureYouWantTo2 =>
      'Czy na pewno chcesz wyczyścić całą historię słuchania? Tego nie można cofnąć.';

  @override
  String get areYouSureYouWantTo3 =>
      'Czy na pewno chcesz zresetować wszystkie preferencje UAC2? Tej akcji nie można cofnąć.';

  @override
  String get artist => 'Wykonawca';

  @override
  String get artistIsNotAvailableForThis =>
      'Artysta nie jest dostępny dla tego utworu';

  @override
  String get artistName => 'Nazwa artysty';

  @override
  String artistUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'artyści',
      one: 'artysta',
    );
    return '$_temp0';
  }

  @override
  String get artists => 'Artyści';

  @override
  String artists2(Object arg1) {
    return 'Artyści $arg1';
  }

  @override
  String get artistsInRotation => 'Artyści w rotacji';

  @override
  String get artwork => 'Okładka';

  @override
  String get artworkCard => 'Karta graficzna';

  @override
  String get artworkPlacement => 'Umieszczenie grafiki';

  @override
  String get artworkPlacement2 => 'Umieszczenie grafiki';

  @override
  String get artworkSize => 'Rozmiar grafiki';

  @override
  String get artworkSize2 => 'Rozmiar grafiki';

  @override
  String get asmrDreams => 'Marzenia ASMR';

  @override
  String atKhzBit(Object arg1, Object arg2) {
    return ' przy ${arg1}kHz/${arg2}bit';
  }

  @override
  String get atLeastOneVersionMustStay =>
      'Przynajmniej jedna wersja musi pozostać.';

  @override
  String get attack => 'Atak';

  @override
  String get audioFocus => 'Fokus dźwięku';

  @override
  String get audioFormat => 'Format dźwięku';

  @override
  String get audioFormatIsDisabled => 'Format audio jest wyłączony';

  @override
  String get audioSignalPath => 'Ścieżka sygnału audio';

  @override
  String get aug => 'sierpień';

  @override
  String get auto => 'Automat';

  @override
  String get autoAdvance => 'Automatyczny postęp';

  @override
  String get autoBeMsbDefaultOnlyChange =>
      'Auto — ustawienie domyślne BE-MSB; zmieniać się tylko wtedy, gdy syczy natywny DSD';

  @override
  String get autoBitPerfectForUsbDacs =>
      'Auto Bit-idealny dla przetworników DAC USB';

  @override
  String get autoFill => 'Automatyczne wypełnianie';

  @override
  String get autoFullView => 'Automatyczny pełny widok';

  @override
  String get autoIdentifyUntaggedAlbums =>
      'Automatycznie identyfikuj nieoznaczone albumy';

  @override
  String get autoNativeDsdOnDapsDop =>
      'Auto — natywny DSD w przetwornikach DAP, DoP w przetwornikach DAC USB, w przeciwnym razie PCM';

  @override
  String get autoReconnect => 'Automatyczne ponowne połączenie';

  @override
  String get autoShowFullViewAfterInactivity =>
      'Automatyczne wyświetlanie pełnego widoku po bezczynności';

  @override
  String get autoU8ByteInterleavedRecommended =>
      'Auto — U8 z przeplotem bajtów (zalecane)';

  @override
  String get autoeqHeadphones => 'Słuchawki z AutoEQ';

  @override
  String get autoeqHeadphones2 => 'Słuchawki z AutoEQ';

  @override
  String get automatic => 'Automatyczny';

  @override
  String get availableDevices => 'Dostępne urządzenia';

  @override
  String b(Object arg1) {
    return 'B$arg1';
  }

  @override
  String get back => 'Wstecz';

  @override
  String get backOnline => 'Powrót do Internetu';

  @override
  String get backToLocker => 'Powrót do Lockera';

  @override
  String get backToReplay => 'Powrót do powtórki';

  @override
  String get backend => 'Zaplecze';

  @override
  String get background => 'Tło';

  @override
  String get backgroundOpacity => 'Nieprzezroczystość tła';

  @override
  String get balance => 'Równowaga';

  @override
  String balance2(Object arg1) {
    return 'Zrównoważ $arg1';
  }

  @override
  String get balanceTempoDampFilterDelaysSize =>
      'Balans, tempo, wilgotność, filtr, opóźnienia, rozmiar, miks i dodatkowe elementy sterujące.';

  @override
  String get balancedQualityAndStability => 'Zrównoważona jakość i stabilność';

  @override
  String get band => 'Zespół';

  @override
  String get bandControls => 'Sterowanie pasmem';

  @override
  String get bandEditors => 'Redaktorzy zespołu';

  @override
  String get bandPass => 'Przepustka zespołu';

  @override
  String bandU2022(Object arg1, Object arg2) {
    return 'Taśma $arg1 • $arg2';
  }

  @override
  String bands(Object arg1) {
    return 'Pasma $arg1/31';
  }

  @override
  String bandsActive(Object activeCount, Object arg1) {
    return 'Pasma $activeCount/$arg1 aktywne';
  }

  @override
  String bandsAdjusted(Object adjustedBands) {
    return 'Wyregulowano pasma $adjustedBands';
  }

  @override
  String bandsAdjusted2(Object adjustedCount, Object arg1) {
    return 'Dostosowano pasma $adjustedCount/$arg1';
  }

  @override
  String bandsPreampDb(Object arg1, Object arg2, Object arg3) {
    return 'Pasma $arg1 · przedwzmacniacz $arg2 dB · $arg3';
  }

  @override
  String get bars => 'Bary';

  @override
  String get bass => 'Bas';

  @override
  String get bassMidTreble => 'Bas, środek i góra';

  @override
  String get bassTreble => 'Bas + Góra';

  @override
  String battery(Object battery) {
    return '$battery% baterii';
  }

  @override
  String get beLsbBigEndianSubslotLsb =>
      'BE-LSB — podszczelina typu big-endian, najpierw LSB';

  @override
  String get beMsbBigEndianSubslotMsb =>
      'BE-MSB — podslot typu big-endian, najpierw MSB (domyślnie)';

  @override
  String get beMsbPackingTheDefaultWire =>
      'Uszczelnienie BE-MSB — domyślna konwencja drutu';

  @override
  String get besideTheSong => 'Obok piosenki';

  @override
  String get bigEndian32BitSubslotMsb =>
      '32-bitowa szczelina podrzędna Big-endian, pierwsze bity MSB';

  @override
  String get bigEndianSubslotLsbFirstBit =>
      'Podszczelina big-endian, bity pierwsze LSB (odwrócone bity).';

  @override
  String bit(Object depth) {
    return '${depth}bit';
  }

  @override
  String get bitDepth => 'Głębia bitowa';

  @override
  String get bitDepth2 => 'Głębia bitowa';

  @override
  String get bitDepths => 'Głębia bitowa';

  @override
  String get bitPerfect => 'BIT-IDEALNY';

  @override
  String get bitPerfect2 => 'Trochę idealnie';

  @override
  String get bitPerfectCapsule => 'Kapsułka Bit-Perfect';

  @override
  String get bitPerfectDapInternal => 'Bit-perfect (wewnętrzny DAP)';

  @override
  String get bitPerfectDapInternalDisabledSoftware =>
      'Bit-perfect (DAP Internal) wyłączony — efekty programowe aktywne.';

  @override
  String get bitPerfectDapInternalEnabledAll =>
      'Włączono funkcję Bit-Perfect (DAP Internal) — pominięte wszystkie procesory DSP.';

  @override
  String get bitPerfectEnabledParametricEqIs =>
      'Włączony tryb Bit-Perfect — korektor parametryczny jest pomijany na bezpośredniej ścieżce USB. Uruchom ponownie aplikację, aby zastosować zmiany w odtwarzaniu.';

  @override
  String get bitPerfectUsbDac => 'Bit-perfect (USB DAC)';

  @override
  String get bitPerfectUsbDacCouldNot =>
      'Nie można włączyć funkcji Bit-Perfect (USB DAC). Sprawdź diagnostykę USB pod kątem przyczyny awarii.';

  @override
  String bitPerfectUsbDacCouldNot2(Object arg1) {
    return 'Nie można włączyć funkcji Bit-Perfect (USB DAC) dla $arg1. Sprawdź diagnostykę USB.';
  }

  @override
  String bitPerfectUsbDacEnabledFor(Object arg1) {
    return 'Funkcja bit-perfect (USB DAC) włączona dla $arg1.';
  }

  @override
  String get bitPerfectVerified => 'Sprawdzone w bit-perfect';

  @override
  String get bitSubslotsLlRrPer => '16-bitowe podsloty: LL|RR na ramkę';

  @override
  String get bitSubslotsLlllRrrrPer =>
      '32-bitowe podsloty: LLLL|RRRR na ramkę (starsza wersja)';

  @override
  String get bitrateAdjustsToSignalQuality =>
      'Szybkość transmisji dostosowuje się do jakości sygnału';

  @override
  String get blocked => 'Zablokowany';

  @override
  String get blue => 'Niebieski';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get bluetoothCodecInfo => 'Informacje o kodeku Bluetooth';

  @override
  String get bluetoothOutput => 'Wyjście Bluetooth';

  @override
  String get boldSaturatedColorsFromAlbumArt =>
      'Odważne, nasycone kolory z okładek albumów.';

  @override
  String get border => 'Granica';

  @override
  String get bothBitPerfectOptionsAreOff =>
      'Obie opcje bit-perfect są wyłączone w tym DAP-ie, więc standardowy silnik jest niedostępny. Nadal możesz używać Rusta przez obój lub izochroniczne złącze USB.';

  @override
  String get bottom => 'Dół';

  @override
  String get bouncy => 'Sprężysty';

  @override
  String get browseByArtworkOpenAnyAlbum =>
      'Przeglądaj według okładek, otwórz dowolny album i przejdź bezpośrednio do listy utworów.';

  @override
  String get browseYourArtistLibrary =>
      'Przeglądaj swoją bibliotekę wykonawców';

  @override
  String get browseYourArtistsExploreTheirDiscographies =>
      'Przeglądaj swoich artystów, odkrywaj ich dyskografie i odtwarzaj ich utwory.';

  @override
  String get buffer => 'Bufor';

  @override
  String build(Object kAppVersion, Object kAppBuild) {
    return '$kAppVersion (kompilacja $kAppBuild)';
  }

  @override
  String get buildingYourMusicHome => 'Buduj swój muzyczny dom';

  @override
  String get builtIn => 'Wbudowany';

  @override
  String by(Object arg1, Object arg2) {
    return '„$arg1” autorstwa $arg2';
  }

  @override
  String get bypassAllDspEqDynamicsCrossfade =>
      'Pomiń wszystkie DSP (EQ, dynamika, crossfade, prędkość) na natywnej, wewnętrznej ścieżce wysokiej rozdzielczości DAP. Wyłącz, aby używać efektów programowych. Wyłączenie Bit-perfect (USB DAC) również to wyłącza.';

  @override
  String get byteInterleavedLrlrStream => 'Przeplatany bajtami: strumień LRLR';

  @override
  String get calmFrequencies => 'Spokojne częstotliwości';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraAccessIsNeededYouCan =>
      'Wymagany jest dostęp do kamery. Możesz to włączyć w ustawieniach Androida.';

  @override
  String get cancel => 'Anuluj';

  @override
  String capMs(Object arg1) {
    return 'czapka $arg1 ms';
  }

  @override
  String get capabilities => 'Możliwości';

  @override
  String get capabilitiesNotAvailable => 'Możliwości niedostępne';

  @override
  String get capabilityState => 'Stan zdolności';

  @override
  String get cast => 'Obsada';

  @override
  String get casting => 'Przesyłanie';

  @override
  String get castingTapToManage => 'Przesyłanie — kliknij, aby zarządzać';

  @override
  String castingTo(Object deviceName) {
    return 'Odlewanie do $deviceName';
  }

  @override
  String castingTo2(Object arg1) {
    return 'Odlewanie do $arg1';
  }

  @override
  String get categories => 'Kategorie';

  @override
  String get ceiling => 'Sufit';

  @override
  String get center => 'Środek';

  @override
  String get centeredWidensToFitYourControls =>
      'Wyśrodkowany; rozszerza się, aby dopasować się do elementów sterujących';

  @override
  String ch(Object channels) {
    return '$channels rozdz';
  }

  @override
  String ch2(Object ch) {
    return '$ch rozdz';
  }

  @override
  String ch3(Object arg1, Object arg2) {
    return '$arg1 / ${arg2}ch';
  }

  @override
  String get changingSampleRateBitDepthOr =>
      'Zmiana częstotliwości próbkowania, głębi bitowej lub obsługi kanałów może spowodować ponowne próbkowanie utworów i może mieć wpływ na jakość odtwarzania, wysokość, prędkość lub stabilność na niektórych urządzeniach.';

  @override
  String get channels => 'Kanały';

  @override
  String channels2(Object arg1) {
    return 'Kanały $arg1';
  }

  @override
  String channels3(Object ch) {
    return 'Kanały $ch';
  }

  @override
  String get checkTheVersionsYouWantTo =>
      'Zaznacz wersje, które chcesz zachować — niezaznaczone wersje zostaną usunięte z Twojej biblioteki. Przynajmniej jeden musi zostać.';

  @override
  String get checkVersionsToKeepUncheckedWill =>
      'Zaznacz wersje, które chcesz zachować — niezaznaczone zostaną usunięte';

  @override
  String get chooseAction => 'Wybierz Akcja';

  @override
  String get chooseAudioEngine => 'Wybierz silnik audio';

  @override
  String get chooseLocationU2026 => 'Wybierz lokalizację…';

  @override
  String get chooseWhichToKeep => 'Wybierz, które chcesz zachować';

  @override
  String get chromecast => 'Chromecasta';

  @override
  String get circularDotsRadiusFollowsAmplitude =>
      'Okrągłe kropki — promień podąża za amplitudą';

  @override
  String get cityBeats => 'Miejskie rytmy';

  @override
  String get claimedByFlick => 'Przedmiot roszczenia Hadoo';

  @override
  String get cleanStraightLineWithPrecisionScrubbing =>
      'Czysta linia prosta dzięki precyzyjnemu szorowaniu.';

  @override
  String get clear => 'Wyczyść';

  @override
  String get clearAll => 'Wyczyść wszystko';

  @override
  String get clearAllUac2Settings => 'Wyczyść wszystkie ustawienia UAC2';

  @override
  String get clearFilters => 'Wyczyść filtry';

  @override
  String get clearHistory => 'Wyczyść historię';

  @override
  String get clearLogs => 'Wyczyścić logi?';

  @override
  String get clearWord => 'Jasne Słowo';

  @override
  String get clearWords => 'Jasne słowa';

  @override
  String get close => 'Zamknij';

  @override
  String get closePreview => 'Zamknij podgląd';

  @override
  String codecApplied(Object arg1) {
    return 'Zastosowano kodek: $arg1';
  }

  @override
  String get codecControl => 'Kontrola kodeków';

  @override
  String get codecForcingUnavailableOnThisDevice =>
      'Wymuszanie kodeków jest niedostępne na tym urządzeniu — ustaw je w Opcjach programisty → Kodek audio Bluetooth.';

  @override
  String get codecInfo => 'Informacje o kodeku';

  @override
  String get codecU0026Audio => 'Kodek i dźwięk';

  @override
  String get collapsed => 'Zwinięty';

  @override
  String get collection => 'Kolekcja';

  @override
  String get color => 'Kolor';

  @override
  String get comingSoon => 'Już wkrótce';

  @override
  String get compatibility => 'Kompatybilność';

  @override
  String get compatibleWithPowerampEq => 'Kompatybilny z korektorem Powerampa';

  @override
  String get compressor => 'Sprężarka';

  @override
  String get compressorOff => 'Sprężarka wyłączona';

  @override
  String get compressorOn => 'Sprężarka włączona';

  @override
  String get connect => 'Połącz';

  @override
  String get connectAMusicServer => 'Podłącz serwer muzyczny';

  @override
  String get connectASubsonicJellyfinWebdavUpnp =>
      'Podłącz serwer Subsonic, Jellyfin, WebDAV, UPnP lub Tidal, aby przesyłać strumieniowo swoją zdalną bibliotekę.';

  @override
  String get connectAUsbDacOrAudio =>
      'Podłącz przetwornik cyfrowo-analogowy USB lub interfejs audio';

  @override
  String get connectListenbrainz => 'Podłącz ListenBrainz';

  @override
  String get connectToScrobbleYourListeningHistory =>
      'Połącz się, aby zeskrobać historię słuchania';

  @override
  String get connectToScrobbleYourMusic => 'Połącz się, aby scrobblować muzykę';

  @override
  String get connectToSubmitYourListeningHistory =>
      'Połącz się, aby przesłać swoją historię słuchania';

  @override
  String get connected => 'Połączono';

  @override
  String get connectedAccount => 'Połączone konto';

  @override
  String connectedAs(Object username) {
    return 'Połączono jako $username';
  }

  @override
  String get connecting => 'Łączenie';

  @override
  String get connection => 'Połączenie';

  @override
  String get connectionBehavior => 'Zachowanie połączenia';

  @override
  String get connectionFailedRetry =>
      'Połączenie nie powiodło się — spróbuj ponownie';

  @override
  String get connectionManagement => 'Zarządzanie połączeniami';

  @override
  String get connectionOk => 'Połączenie OK';

  @override
  String get connectionStatus => 'Stan połączenia';

  @override
  String containsValuesOutsideTheSupportedRanges(Object presetName) {
    return '„$presetName” zawiera wartości spoza obsługiwanych zakresów; te zostały dostosowane:';
  }

  @override
  String get content => 'Treść';

  @override
  String get contentControls => 'Treść i sterowanie';

  @override
  String get contentPlacement => 'Umieszczenie treści';

  @override
  String get contentPlacement2 => 'Umieszczanie treści';

  @override
  String get continueLabel => 'Dalej';

  @override
  String conversionFailed(Object error) {
    return 'Konwersja nie powiodła się: $error';
  }

  @override
  String convertedSuccessfully(Object fileName) {
    return 'Konwersja $fileName przebiegła pomyślnie';
  }

  @override
  String get convertingAudio => 'Konwersja dźwięku...';

  @override
  String convertingToWav(Object fileName) {
    return 'Konwersja $fileName do formatu WAV...';
  }

  @override
  String get convolverImpulseResponse => 'Konwolwer / odpowiedź impulsowa';

  @override
  String copies(Object arg1, Object arg2) {
    return '$arg1 • Kopie $arg2';
  }

  @override
  String get copy => 'Kopiuj';

  @override
  String get copyLink => 'Kopiuj link';

  @override
  String get copyYourUserTokenFromListenbrainz =>
      'Skopiuj token użytkownika z ustawień ListenBrainz i wklej go poniżej.';

  @override
  String get copyright => 'Prawa autorskie';

  @override
  String get cornerRadius => 'Promień narożnika';

  @override
  String get cosmicOrchestra => 'Kosmiczna Orkiestra';

  @override
  String get couldNotConnectToLastFm =>
      'Nie można połączyć się z Last.fm. Sprawdź swoje dane uwierzytelniające API i spróbuj ponownie.';

  @override
  String get couldNotConnectToListenbrainzCheck =>
      'Nie można połączyć się z ListenBrainz. Sprawdź swój token i spróbuj ponownie.';

  @override
  String get couldNotLoadAlbumSongs =>
      'Nie udało się załadować utworów z albumu';

  @override
  String get couldNotCreateThePosterImage =>
      'Nie można utworzyć obrazu plakatu.';

  @override
  String get couldNotLoadArtistSongs =>
      'Nie udało się wczytać utworów wykonawcy';

  @override
  String couldNotLoadIr(Object e) {
    return 'Nie można załadować IR: $e';
  }

  @override
  String get couldNotLoadSession => 'Nie udało się wczytać sesji';

  @override
  String get couldNotOpenBrowser => 'Nie można otworzyć przeglądarki.';

  @override
  String get couldNotOpenKoFiPlease =>
      'Nie można otworzyć Ko-fi. Spróbuj ponownie.';

  @override
  String couldNotOpenLink2(Object e) {
    return 'Nie można otworzyć łącza: $e';
  }

  @override
  String get couldNotOpenThatPhotoTry =>
      'Nie można otworzyć tego zdjęcia. Wypróbuj inny obraz.';

  @override
  String get couldNotOpenThePlayStore => 'Nie można otworzyć Sklepu Play.';

  @override
  String couldNotOpenThePlayStore2(Object error) {
    return 'Nie można otworzyć Sklepu Play: $error';
  }

  @override
  String get couldNotReadTheCoverColors =>
      'Nie udało się odczytać kolorów okładki. Sygnał jest nadal dostępny.';

  @override
  String get couldNotReadTheSelectedLyrics =>
      'Nie można odczytać wybranego pliku z tekstami.';

  @override
  String get couldNotSaveTheLyricsFile => 'Nie można zapisać pliku z tekstami.';

  @override
  String get couldNotSaveYourRecapPlease =>
      'Nie udało się zapisać podsumowania. Spróbuj ponownie.';

  @override
  String get couldNotUseTheSelectedLyrics =>
      'Nie można użyć wybranego pliku z tekstami.';

  @override
  String get couldnTOpenTheBrowserAutomatically =>
      'Nie można automatycznie otworzyć przeglądarki. Autoryzuj na dowolnym urządzeniu za pomocą tego linku — zakończymy logowanie, gdy to zrobisz:';

  @override
  String get countingFiles => 'Liczenie plików…';

  @override
  String get create => 'Utwórz';

  @override
  String get createACollection => 'Utwórz kolekcję';

  @override
  String get createACustomPreset => 'Utwórz niestandardowe ustawienie wstępne';

  @override
  String get createAPlaylistImportAnM3u =>
      'Utwórz playlistę, zaimportuj M3U lub pozwól, aby powyższe miksy utrzymały sesję.';

  @override
  String get createLyrics => 'Twórz teksty';

  @override
  String get createNewPlaylist => 'Utwórz nową playlistę';

  @override
  String get createNewPlaylist2 => 'Utwórz nową listę odtwarzania';

  @override
  String get createPlaylist => 'Utwórz listę odtwarzania';

  @override
  String get createPlaylistFromSelected => 'Utwórz playlistę z wybranych';

  @override
  String get createYourFirstPlaylistOrJump =>
      'Utwórz swoją pierwszą playlistę lub przejdź do zapisanych kolekcji.';

  @override
  String get createYourFirstPlaylistToOrganize =>
      'Utwórz swoją pierwszą listę odtwarzania, aby uporządkować \n swoje ulubione utwory';

  @override
  String created(Object arg1) {
    return 'Utworzono $arg1';
  }

  @override
  String createdAndAddedSong(Object arg1) {
    return 'Utworzono $arg1 i dodano utwór';
  }

  @override
  String createdAndAddedSongs(Object name, Object arg1) {
    return 'Utworzono $name i dodano utwory $arg1';
  }

  @override
  String get creativeFx => 'Kreatywne efekty';

  @override
  String credentialsRejectedByReEnterThe(Object arg1) {
    return 'Poświadczenia odrzucone przez $arg1. Wprowadź hasło ponownie.';
  }

  @override
  String get credentialsSavedSuccessfully =>
      'Dane uwierzytelniające zostały pomyślnie zapisane!';

  @override
  String get crystalCaverns => 'Kryształowe Groty';

  @override
  String get cueSheetTracksCannotBeEdited =>
      'Nie można edytować ścieżek arkusza CUE.';

  @override
  String get cueSheetTracksCannotBeEdited2 =>
      'Nie można edytować ścieżek arkusza CUE';

  @override
  String get currentArtwork => 'Aktualna grafika';

  @override
  String get currentCustomArt => 'Aktualna grafika niestandardowa';

  @override
  String get currentPlaybackMode => 'Bieżący tryb odtwarzania';

  @override
  String currentRoute(Object arg1) {
    return 'Obecna trasa: $arg1.';
  }

  @override
  String get currentSongPreviewOnly => 'Bieżący utwór · tylko podgląd';

  @override
  String get currentStreak => 'Aktualna passa';

  @override
  String get curvePreview => 'Podgląd krzywej';

  @override
  String get curvedWave => 'Zakrzywiona fala';

  @override
  String get custom => 'Niestandardowe';

  @override
  String get customFormat => 'Niestandardowy format';

  @override
  String get customFormatForcesPlaybackToThe =>
      'Format niestandardowy wymusza odtwarzanie w wybranym formacie wyjściowym. Jeśli wybrana częstotliwość próbkowania, głębia bitowa lub kanały nie odpowiadają utworowi lub urządzeniu, możesz usłyszeć zmieniony dźwięk, wysokość, prędkość lub niestabilność.';

  @override
  String get customFormatIsDisabledInBit =>
      'Format niestandardowy jest wyłączony w trybie Bit-perfect (USB DAC), ponieważ wymagane jest dokładne dopasowanie częstotliwości próbkowania. Wyłącz opcję Bit-perfect (USB DAC), aby ustawić niestandardowe formaty.';

  @override
  String get customFormatIsUnavailableBecauseAudio =>
      'Format niestandardowy jest niedostępny, ponieważ w Ustawieniach wyłączona jest opcja Format audio.';

  @override
  String get customWidth => 'Niestandardowa szerokość';

  @override
  String get customizeAudioDisplayNavigationAnd =>
      'Dostosuj dźwięk, wyświetlacz, nawigację i integracje.';

  @override
  String get customizeBottomBar => 'Dostosuj dolny pasek';

  @override
  String dAgo(Object arg1) {
    return '${arg1}d temu';
  }

  @override
  String dAgo2(Object arg1) {
    return '${arg1}d temu';
  }

  @override
  String get dacClaim => 'Roszczenie DAC';

  @override
  String dacWillBeOfferedAgain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przetworniki DAC $count',
      one: 'Przetwornik cyfrowo-analogowy $count',
    );
    return '$_temp0 będą oferowane ponownie.';
  }

  @override
  String get daily => 'Codziennie';

  @override
  String get damp => 'Wilgotny';

  @override
  String get dapNativeBitOrder => 'Natywna kolejność bitów DAP';

  @override
  String get dapNativeByteGrouping => 'Natywne grupowanie bajtów DAP';

  @override
  String get dark => 'Ciemny';

  @override
  String get date => 'Data';

  @override
  String get dateAdded => 'Data dodania';

  @override
  String get dateAddedNewest => 'Data dodania (najnowsza)';

  @override
  String get dateAddedOldest => 'Data dodania (najstarszy)';

  @override
  String get dayStreak => 'passa dnia';

  @override
  String get dayStreak2 => 'Pasja dnia';

  @override
  String get dayStreak3 => 'Seria dni';

  @override
  String dayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dni',
      one: 'dzień',
    );
    return '$_temp0';
  }

  @override
  String db10(Object arg1) {
    return '$arg1 dB';
  }

  @override
  String db13(Object arg1) {
    return '$arg1 dB';
  }

  @override
  String db15(Object arg1, Object arg2) {
    return '$arg1% $arg2 dB';
  }

  @override
  String db2(Object value) {
    return '$value dB';
  }

  @override
  String db9(Object arg1) {
    return '$arg1 dB';
  }

  @override
  String dbCut(Object arg1) {
    return '$arg1 Tłumienie dB';
  }

  @override
  String dbMax(Object arg1) {
    return '$arg1 dB maks';
  }

  @override
  String get deactivateFallback => 'Dezaktywuj opcję powrotu';

  @override
  String get dec => 'grudzień';

  @override
  String get decode => 'Dekodować';

  @override
  String get deepEarth => 'Głęboka Ziemia';

  @override
  String get defaultAndroidPlaybackEngineUsedBy =>
      'Domyślny silnik odtwarzania Androida używany obecnie przez Hadoo.';

  @override
  String get defaultAndroidPlayerPlaysEverything =>
      'Domyślny odtwarzacz na Androida — odtwarza wszystko niezawodnie. Najbezpieczniejszy wybór dla większości słuchaczy.';

  @override
  String get delays => 'Opóźnienia';

  @override
  String get delete => 'Usuń';

  @override
  String deleteAndAllSongsAndPlaylists(Object arg1) {
    return 'Usunąć „$arg1” i wszystkie zsynchronizowane z nim utwory i listy odtwarzania? Pobrane pliki z pamięci podręcznej są zachowywane.';
  }

  @override
  String get deleteFile => 'Usuń plik';

  @override
  String get deleteFiles => 'Usuń pliki';

  @override
  String get deletePlaylist => 'Usuń playlistę';

  @override
  String get deletePreset => 'Usunąć ustawienie wstępne?';

  @override
  String get deleteSelected => 'Usuń wybrane';

  @override
  String get deleteSong => 'Usuń utwór';

  @override
  String get deleteSong2 => 'Usunąć utwór?';

  @override
  String get deleteSong3 => 'Usuń utwór';

  @override
  String deleteSongs(Object arg1) {
    return 'Usunąć utwory $arg1?';
  }

  @override
  String get deleteSongs2 => 'Usuń utwory';

  @override
  String deleteThisCannotBeUndone(Object arg1) {
    return 'Usunąć „$arg1”? Tego nie można cofnąć.';
  }

  @override
  String deleted(Object arg1) {
    return 'Usunięto „$arg1”';
  }

  @override
  String deletedSongs(Object arg1) {
    return 'Usunięto utwory $arg1';
  }

  @override
  String get deselectAll => 'Odznacz wszystko';

  @override
  String get designed => 'Zaprojektowane';

  @override
  String get details => 'Szczegóły';

  @override
  String get developerMode => 'Tryb programisty';

  @override
  String get developerOptionsIsDisabledEnableIt =>
      'Opcje programistyczne są wyłączone. Włącz tę funkcję w Ustawieniach → Informacje o telefonie (dotknij Numer kompilacji 7 razy), a następnie spróbuj ponownie.';

  @override
  String get device => 'Urządzenie';

  @override
  String get deviceCapabilities => 'Możliwości urządzenia';

  @override
  String get deviceConnected => 'Urządzenie podłączone';

  @override
  String get deviceDac => 'Urządzenie DAC';

  @override
  String get deviceDacVolume => 'Głośność DAC urządzenia';

  @override
  String get deviceDisconnected => 'Urządzenie odłączone';

  @override
  String get deviceInformation => 'Informacje o urządzeniu';

  @override
  String get deviceType => 'Typ urządzenia';

  @override
  String get devices => 'Urządzenia';

  @override
  String get direct => 'Bezpośrednie';

  @override
  String get directAlsaOutputIsActiveAnd =>
      'Bezpośrednie wyjście ALSA jest aktywne i omija serwer audio Androida.';

  @override
  String get directLibusbIsochronousUsbEngineBest =>
      'Bezpośredni izochroniczny silnik USB libusb. Najlepiej w połączeniu z Bit-perfect (USB DAC) w celu zweryfikowania odtwarzania zewnętrznego przetwornika DAC.';

  @override
  String get directUsb => 'Bezpośrednie USB';

  @override
  String get directUsbDeviceManaged =>
      'Bezpośrednie zarządzanie urządzeniami USB';

  @override
  String get directUsbExperimental =>
      'Bezpośredni eksperymentalny interfejs USB';

  @override
  String get disabled => 'Niepełnosprawny';

  @override
  String get disabledInBitPerfectUsbDac =>
      'Wyłączone w trybie Bit-perfect (USB DAC) (wymagana jest dokładna szybkość)';

  @override
  String get disabledWhileBothBitPerfectOptions =>
      'Wyłączone, gdy obie opcje bit-perfect są wyłączone w tym DAP.';

  @override
  String get disc => 'Dysk';

  @override
  String get disc2 => 'Tarcza #';

  @override
  String get discard => 'Odrzuć';

  @override
  String get discardChanges => 'Odrzucić zmiany?';

  @override
  String get discardChanges2 => 'Odrzucić zmiany?';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String disconnectFrom(Object arg1) {
    return 'Odłącz od $arg1';
  }

  @override
  String get disconnectLastFm => 'Odłączyć Last.fm?';

  @override
  String get disconnectListenbrainz => 'Odłączyć ListenBrainz?';

  @override
  String get discoversDlnaUpnpAndChromecastReceivers =>
      'Wykrywa odbiorniki DLNA, UPnP i Chromecast w Twojej sieci';

  @override
  String get dismiss => 'Odrzuć';

  @override
  String get displayFileFormatAndBitrateIn =>
      'Wyświetl format pliku i szybkość transmisji w trybie immersyjnym';

  @override
  String get displayFileFormatAndBitrateIn2 =>
      'Wyświetl format pliku i szybkość transmisji w trybie karty graficznej';

  @override
  String get displayTheAlbumNameInArtwork =>
      'Wyświetl nazwę albumu w trybie karty graficznej';

  @override
  String get displayTheArtistNameInArtwork =>
      'Wyświetl nazwę artysty w trybie karty graficznej';

  @override
  String get displayTheArtistNameInImmersive =>
      'Wyświetlaj nazwę artysty w trybie immersyjnym';

  @override
  String get displayTheTrackTitleInArtwork =>
      'Wyświetl tytuł utworu w trybie karty graficznej';

  @override
  String get displayTheTrackTitleInImmersive =>
      'Wyświetl tytuł utworu w trybie immersyjnym';

  @override
  String get dlnaAndUpnpReceiversAreControlled =>
      'Odbiorniki DLNA i UPnP są sterowane bezpośrednio w czystym Dart — bez dodatkowych zależności. Obsługa Chromecasta korzysta z natywnego pakietu SDK Cast. Można przesyłać źródła sieciowe (Subsonic, WebDAV, Jellyfin, UPnP), pliki lokalne i utwory zapisane w pamięci podręcznej — lokalne źródła są obsługiwane bezpośrednio z tego telefonu. Podczas przesyłania klawisze głośności i systemowy panel głośności sterują podłączonym urządzeniem.';

  @override
  String get dlnaUpnp => 'DLNA/UPnP';

  @override
  String get donTShowAgainToday => 'Nie pokazuj się dzisiaj więcej';

  @override
  String get done => 'Gotowe';

  @override
  String get dop => 'DoP';

  @override
  String get dots => 'Kropki';

  @override
  String get doubleTapABandToReset =>
      'Kliknij dwukrotnie opaskę, aby zresetować';

  @override
  String get doubleTapToReset => 'Kliknij dwukrotnie, aby zresetować';

  @override
  String get doubleTapToResetThisBand =>
      'Kliknij dwukrotnie, aby zresetować to pasmo';

  @override
  String down(Object arg1) {
    return '$arg1 w dół';
  }

  @override
  String dp(Object arg1) {
    return '$arg1 dp';
  }

  @override
  String dp2(Object arg1) {
    return '$arg1 dp';
  }

  @override
  String dp3(Object arg1) {
    return '$arg1 dp';
  }

  @override
  String get dragABoundaryToStretchOr =>
      'Przeciągnij granicę, aby rozciągnąć lub zmniejszyć słowo przed nią. Ostatnia granica przesuwa następną linię.';

  @override
  String get dragBandsUpOrDown => 'Przeciągnij pasma w górę lub w dół';

  @override
  String get dragToChangeFrequencyGain =>
      'Przeciągnij, aby zmienić częstotliwość i wzmocnienie';

  @override
  String get dragToMovePinchToWiden =>
      'Przeciągnij, aby przesunąć. • Ściśnij, aby poszerzyć/zawęzić';

  @override
  String get dragVerticallyToChangeGain =>
      'Przeciągnij w pionie, aby zmienić wzmocnienie';

  @override
  String driftMs(Object arg1) {
    return 'Drift $arg1 ms';
  }

  @override
  String get dsdMode => 'Tryb DSD';

  @override
  String get dsdOutputMode => 'Tryb wyjścia DSD';

  @override
  String get dsdStream => 'Strumień DSD';

  @override
  String get duplicateCleaner => 'Duplikat Cleaner';

  @override
  String get duplicatesRemovedUsingRecommendedPicks =>
      'Duplikaty zostały usunięte przy użyciu zalecanych typów.';

  @override
  String get duration => 'Czas trwania';

  @override
  String get durationMatch => 'Dopasowanie czasu trwania';

  @override
  String get dynamics => 'Dynamika';

  @override
  String get earlier => 'Wcześniej';

  @override
  String get earlierStandoutsPulledBackIntoView =>
      'Wcześniejsze wyróżnienia zostały przywrócone do widoku z Twojej historii słuchania.';

  @override
  String get editCredentials => 'Edytuj dane uwierzytelniające';

  @override
  String get editDescription => 'Edytuj opis';

  @override
  String get editDescription2 => 'Edytuj opis';

  @override
  String get editMetadata => 'Edytuj metadane';

  @override
  String get editServer => 'Edytuj serwer';

  @override
  String get editSync => 'Edytuj i synchronizuj';

  @override
  String get editText => 'Edytuj tekst';

  @override
  String get editToken => 'Edytuj token';

  @override
  String get empty => 'Pusty';

  @override
  String get emptyLine => '(Pusta linia)';

  @override
  String get enable => 'Włącz';

  @override
  String get enable432HzTuning => 'Włączyć strojenie 432 Hz?';

  @override
  String get enableEqToEdit => 'Włącz EQ, aby edytować';

  @override
  String get enabled => 'Włączone';

  @override
  String get endpoint => 'Punkt końcowy';

  @override
  String get engine => 'Silnik';

  @override
  String enterAValidNumber(Object label) {
    return 'Wprowadź prawidłowy numer $label';
  }

  @override
  String enterAValueFromTo(Object arg1, Object arg2) {
    return 'Wprowadź wartość od $arg1% do $arg2%';
  }

  @override
  String get enterAYear19999 => 'Wprowadź rok (1–9999)';

  @override
  String get enterYourApiKey => 'Wprowadź swój klucz API';

  @override
  String get enterYourSharedSecret => 'Wpisz swój wspólny sekret';

  @override
  String ep(Object arg1) {
    return 'EP $arg1';
  }

  @override
  String get equalizer => 'Korektor';

  @override
  String error(Object error) {
    return 'Błąd: $error';
  }

  @override
  String error2(Object arg1) {
    return 'Błąd: $arg1';
  }

  @override
  String get error3 => 'Błąd';

  @override
  String errorLoadingCapabilities(Object error) {
    return 'Błąd ładowania możliwości: $error';
  }

  @override
  String get errorLoadingPlaylists => 'Błąd podczas ładowania playlist';

  @override
  String errorLoadingPlaylists2(Object error) {
    return 'Błąd podczas ładowania list odtwarzania: $error';
  }

  @override
  String get errorLoadingPreference => 'Błąd podczas ładowania preferencji';

  @override
  String get errorLoadingSongs => 'Błąd podczas ładowania utworów';

  @override
  String get etherealTones => 'Eteryczne tony';

  @override
  String get everyAlbumHasArtistAndAlbum =>
      'Każdy album ma tagi wykonawcy i albumu.';

  @override
  String get exactMatch => 'Dokładne dopasowanie';

  @override
  String get exclusiveDirectPcmIsActiveAnd =>
      'Ekskluzywny bezpośredni PCM jest aktywny i omija mikser Androida z natywną szybkością utworu.';

  @override
  String get exclusiveUsbBitPerfectReEngaged =>
      'Ekskluzywny bit-perfect USB ponownie włączony.';

  @override
  String get exclusiveUsbDroppedToTheAndroid =>
      'Ekskluzywne złącze USB trafiło do miksera Android. Bit-Perfect jest wstrzymany.';

  @override
  String get exclusiveUsbIsActiveAndBypassing =>
      'Ekskluzywne USB jest aktywne i omija mikser Androida.';

  @override
  String get exclusiveUsbIsStillUnavailableCheck =>
      'Ekskluzywne złącze USB jest nadal niedostępne. Sprawdź diagnostykę USB.';

  @override
  String get expanded => 'Rozszerzony';

  @override
  String get experimental => 'Eksperymentalny';

  @override
  String get experimentalDownTunePlaybackBy432 =>
      'Eksperymentalne — dostrajanie odtwarzania o 432/440. Wyłącza to przejście bit-perfect i uruchamia ścieżkę DSP.';

  @override
  String get exportAsM3u => 'Eksportuj jako .m3u';

  @override
  String get exportAsM3u8 => 'Eksportuj jako .m3u8';

  @override
  String get exportCsv => 'Eksportuj plik CSV';

  @override
  String get exportCurrentPreset => 'Eksportuj bieżące ustawienie wstępne';

  @override
  String get exportEqualizerPreset => 'Eksportuj ustawienie wstępne korektora';

  @override
  String exportFailed(Object e) {
    return 'Eksport nie powiódł się: $e';
  }

  @override
  String get exportFormat => 'Format eksportu';

  @override
  String get exportTxt => 'Eksportuj TXT';

  @override
  String exportedPresetTo(Object savePath) {
    return 'Wyeksportowano ustawienie wstępne do $savePath';
  }

  @override
  String exportedPresetTo2(Object fallbackPath) {
    return 'Wyeksportowano ustawienie wstępne do $fallbackPath';
  }

  @override
  String exportedSongsTo(Object arg1, Object arg2) {
    return 'Wyeksportowano utwory $arg1 do „$arg2”.';
  }

  @override
  String get externalLabel => 'Zewnętrzne';

  @override
  String get externalSongsCannotBeEdited =>
      'Nie można edytować utworów zewnętrznych.';

  @override
  String get externalSongsCannotBeEdited2 =>
      'Nie można edytować utworów zewnętrznych';

  @override
  String get extraCovers => 'Dodatkowe osłony';

  @override
  String get failedToActivateFallback => 'Nie udało się aktywować powrotu';

  @override
  String failedToAddToFavorites(Object arg1) {
    return 'Nie udało się dodać „$arg1” do ulubionych';
  }

  @override
  String get failedToDeactivateFallback =>
      'Nie udało się dezaktywować powrotu zastępczego';

  @override
  String get failedToImportPresetFile =>
      'Nie udało się zaimportować gotowego pliku.';

  @override
  String failedToSaveMetadata(Object e) {
    return 'Nie udało się zapisać metadanych: $e';
  }

  @override
  String get failedToSaveMetadata2 => 'Nie udało się zapisać metadanych.';

  @override
  String get failedToStartStreaming =>
      'Nie udało się rozpocząć przesyłania strumieniowego';

  @override
  String get failedToStopStreaming =>
      'Nie udało się zatrzymać przesyłania strumieniowego';

  @override
  String get faintHueShiftFromAlbumArt =>
      'Lekka zmiana odcienia w stosunku do okładek albumów.';

  @override
  String get fallback => 'Powrót';

  @override
  String get fallbackAudio => 'Dźwięk zastępczy';

  @override
  String get fallbackAudioActivated => 'Włączono dźwięk zastępczy';

  @override
  String get fallbackAudioDeactivated => 'Dźwięk zastępczy wyłączony';

  @override
  String get fallbackAudioWillBeUsedIf =>
      'W przypadku awarii urządzenia UAC2 zostanie użyty dźwięk zastępczy';

  @override
  String get fastDirectTrackingImmediateResponse =>
      'Szybkie bezpośrednie śledzenie — natychmiastowa reakcja';

  @override
  String get favoriteAll => 'Ulubione wszystkie';

  @override
  String get favoriteSongs => 'Ulubione piosenki';

  @override
  String get favorites => 'Ulubione';

  @override
  String get favoritesYouHaveNotRevisitedLately =>
      'Ulubione, do których ostatnio nie wracałeś';

  @override
  String get feb => 'luty';

  @override
  String get feedback => 'Informacje zwrotne';

  @override
  String get file => 'Plik';

  @override
  String get fileInformation => 'Informacje o pliku';

  @override
  String get filePath => 'Ścieżka pliku';

  @override
  String files2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pliki $count',
      one: 'Plik $count',
    );
    return '$_temp0';
  }

  @override
  String get filter => 'Filtruj';

  @override
  String get filterByFormat => 'FILTRUJ WEDŁUG FORMATU';

  @override
  String get filterLogs => 'Filtruj logi…';

  @override
  String get findAndCleanUpDuplicateSongs =>
      'Znajdź i usuń zduplikowane utwory';

  @override
  String get findSongsArtistsAlbumsFolders =>
      'Znajdź utwory, wykonawców, albumy, foldery…';

  @override
  String finishingMetadataForSongs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kończę metadane utworów $count…',
      one: 'Kończę metadane utworu $count…',
    );
    return '$_temp0';
  }

  @override
  String get finishingUp => 'Kończę…';

  @override
  String get fix => 'Napraw';

  @override
  String get fixMissingMetadata => 'Napraw brakujące metadane';

  @override
  String get fixedBands => '31 stałych pasm';

  @override
  String fixedCenterFrequenciesWithADb(Object arg1) {
    return 'Stałe częstotliwości środkowe z zakresem dB $arg1. Kliknij, aby wejść w interakcję.';
  }

  @override
  String get flac24Bit96Khz => 'FLAC · 24 bity / 96 kHz';

  @override
  String get flat => 'Mieszkanie';

  @override
  String get flatResponse => 'Płaska odpowiedź';

  @override
  String get flickCanAttemptToPreferA =>
      'Hadoo może próbować preferować określony kodek powyżej, ale sukces zależy od urządzenia, zestawu słuchawkowego i wersji Androida. Wymuszanie kodeków wykorzystuje ukryty systemowy interfejs API i może nie działać na urządzeniach nierootowanych.';

  @override
  String get flickPreview => 'Podgląd Hadoo';

  @override
  String get flickReplay => 'Powtórka Hadoo';

  @override
  String get flickWillForceYourChosenCodec =>
      'Hadoo wymusi połączenie z wybranym kodekiem';

  @override
  String get folder => 'Folder';

  @override
  String get folderLimit => 'LIMIT FOLDERÓW';

  @override
  String get folderName => 'Nazwa folderu';

  @override
  String folderOf2(Object current, Object total) {
    return 'Folder $current z $total';
  }

  @override
  String get folderSongCount => 'Liczba utworów w folderze';

  @override
  String get folders => 'Foldery';

  @override
  String get foldersShownPerPage => 'Foldery wyświetlane na stronie';

  @override
  String get fontScale => 'Skala czcionki';

  @override
  String get footerLine => 'Linia stopki';

  @override
  String get forceDop => 'Wymuś DoP';

  @override
  String get forceDopAlwaysUseDsdOver =>
      'Force DoP — zawsze używaj DSD zamiast PCM (USB DAC)';

  @override
  String get forcePcm => 'Wymuś PCM';

  @override
  String get forcePcmAlwaysConvertDsdTo =>
      'Force PCM — Zawsze konwertuj DSD na PCM';

  @override
  String get format => 'Format';

  @override
  String get formatControlsAreDisabledTheEngine =>
      'Kontrole formatu są wyłączone. Silnik używa swojego domyślnego formatu.';

  @override
  String get formatStrategy => 'Strategia formatu';

  @override
  String get formatStrategyAndCustomFormatControls =>
      'Strategia formatu i niestandardowe elementy sterujące formatem są aktywne.';

  @override
  String get formatStrategyIsDisabledInBit =>
      'Strategia formatowania jest wyłączona w trybie Bit-perfect (USB DAC), ponieważ wymagane jest dokładne dopasowanie częstotliwości próbkowania. Wyłącz opcję Bit-perfect (USB DAC), aby zmienić preferencje formatu.';

  @override
  String get formatStrategyIsUnavailableBecauseAudio =>
      'Strategia formatowania jest niedostępna, ponieważ w Ustawieniach wyłączona jest opcja Format audio.';

  @override
  String foundOnline(Object arg1) {
    return 'Znaleziono „$arg1” w Internecie.';
  }

  @override
  String frPkt(Object arg1) {
    return '$arg1 fr/pkt';
  }

  @override
  String get freq => 'Częstotliwość';

  @override
  String get frequency => 'Częstotliwość';

  @override
  String get frequencyFocus => 'Fokus częstotliwości';

  @override
  String get freshAdditions => 'Świeże dodatki';

  @override
  String from(Object sourceLabel) {
    return 'Od $sourceLabel';
  }

  @override
  String get fromSquareCornersToARounded =>
      'Od kwadratowych narożników po zaokrąglony pasek';

  @override
  String get fullBleedAlbumArtWithThe =>
      'Pełna okładka albumu z aktualnym kinowym wyglądem.';

  @override
  String get fullPlayer => 'Pełny gracz';

  @override
  String get fullSpectrum => 'Pełne spektrum';

  @override
  String get fullViewCardSize => 'Rozmiar karty w pełnym widoku';

  @override
  String get fullViewCardSize2 => 'Rozmiar karty w pełnym widoku';

  @override
  String get fullscreen => 'Pełny ekran';

  @override
  String get fxOff => 'Efekty wyłączone';

  @override
  String get fxOn => 'Efekty włączone';

  @override
  String get gain => 'Zysk';

  @override
  String get gallery => 'Galeria';

  @override
  String get gapAboveNavigation => 'Przerwa nad nawigacją';

  @override
  String gb(Object arg1) {
    return '$arg1 GB';
  }

  @override
  String get generatedFromYourListeningHabitsFavorites =>
      'Wygenerowane na podstawie Twoich nawyków słuchowych, ulubionych i najnowszych dodatków.';

  @override
  String get genre => 'Gatunek';

  @override
  String get getStarted => 'Rozpocznij';

  @override
  String get getYourApiCredentials => 'Uzyskaj dane uwierzytelniające API';

  @override
  String get goToAlbum => 'Przejdź do albumu';

  @override
  String get goToArtist => 'Przejdź do Artysty';

  @override
  String get goodAfternoon => 'Dzień dobry';

  @override
  String get goodEvening => 'Dobry wieczór';

  @override
  String get goodMorning => 'Dzień dobry';

  @override
  String get gotIt => 'Rozumiem';

  @override
  String get grantBluetoothAccess => 'Przyznaj dostęp Bluetooth';

  @override
  String get graphic => 'Grafika';

  @override
  String get graphicEq => 'Korektor graficzny';

  @override
  String get green => 'Zielony';

  @override
  String get groupingByTitleArtistThisIs =>
      'Grupowanie według tytułu i wykonawcy — zwykle jest to szybkie.';

  @override
  String get groups => 'Grupy';

  @override
  String groupsToRemove(Object arg1, Object arg2) {
    return 'Grupy $arg1 • $arg2 do usunięcia';
  }

  @override
  String groupsToRemove2(Object arg1, Object toRemove) {
    return 'Grupy $arg1 • $toRemove do usunięcia';
  }

  @override
  String get growsFurtherIfLargerSystemText =>
      'Rośnie dalej, jeśli większy tekst systemowy wymaga miejsca';

  @override
  String hAgo(Object arg1) {
    return '${arg1}h temu';
  }

  @override
  String get hardwareUsbDac => 'Sprzęt (przetwornik cyfrowo-analogowy USB)';

  @override
  String get hardwareVolumeIsDetectedButWrites =>
      'Wykryto wolumin sprzętowy, ale zapisy pozostają zablokowane, gdy aktywne jest bezpośrednie odtwarzanie na żywo z USB.';

  @override
  String get hasArtwork => 'Posiada grafikę';

  @override
  String get heavyRotation => 'Ciężka rotacja';

  @override
  String get held => 'Trzymane';

  @override
  String get hiResDirect => 'Bezpośrednio w wysokiej rozdzielczości';

  @override
  String get hideLyrics => 'Ukryj teksty';

  @override
  String get hidePassword => 'Ukryj hasło';

  @override
  String get hideVisualizer => 'Ukryj wizualizator';

  @override
  String get hideVisualizer2 => 'Ukryj wizualizator';

  @override
  String get highFrequenciesOnly => 'Tylko wysokie częstotliwości';

  @override
  String get highPass => 'Wysoka Przełęcz';

  @override
  String get highQuality => 'Wysoka jakość';

  @override
  String get highQualityEngine => 'Silnik wysokiej jakości';

  @override
  String get highQualityWidelySupported => 'Wysoka jakość, szerokie wsparcie';

  @override
  String get highResolutionAptx => 'Wysoka rozdzielczość aptX';

  @override
  String get highShelf => 'Wysoka półka';

  @override
  String get highestBitrateUpTo990Kbps => 'Najwyższy bitrate (do 990 kbps)';

  @override
  String get highestQuality => 'Najwyższa jakość';

  @override
  String get historyCleared => 'Historia wyczyszczona';

  @override
  String hourUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'godziny',
      one: 'godzina',
    );
    return '$_temp0';
  }

  @override
  String get httpBasicNeedsItRecoverableStored =>
      'HTTP Basic wymaga odzyskania; zapisane w postaci zakodowanej';

  @override
  String hz(Object rate) {
    return '$rate Hz';
  }

  @override
  String hz3(Object hz) {
    return '$hz Hz';
  }

  @override
  String get hz5 => 'Hz';

  @override
  String hz6(Object arg1) {
    return '$arg1 Hz';
  }

  @override
  String get hzTuning => 'Strojenie 432 Hz';

  @override
  String identified(int count, Object note) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return 'Zidentyfikowany $_temp0$note.';
  }

  @override
  String get identifyAlbum => 'Zidentyfikuj album';

  @override
  String get identifyAlbum2 => 'Identyfikuj album';

  @override
  String get idle => 'Bezczynny';

  @override
  String get immersive => 'Wciągające';

  @override
  String importFailed(Object e) {
    return 'Import nie powiódł się: $e';
  }

  @override
  String get importM3uM3u8 => 'Importuj M3U/M3U8';

  @override
  String get importPresetFile => 'Importuj gotowy plik';

  @override
  String imported(Object arg1) {
    return 'Zaimportowano „$arg1”';
  }

  @override
  String get importedArtIsSavedInsideThe =>
      'Zaimportowana grafika jest zapisywana w aplikacji i synchronizowana z każdym utworem w tym albumie.';

  @override
  String get importedArtIsSavedInsideThe2 =>
      'Zaimportowana grafika jest zapisywana w aplikacji tylko w przypadku tego utworu.';

  @override
  String importedWithSongs(Object arg1, Object arg2, Object unmatchedText) {
    return 'Zaimportowano utwór „$arg1” z utworami $arg2.$unmatchedText';
  }

  @override
  String get impulseResponse => 'Odpowiedź impulsowa';

  @override
  String inLabel(Object folder) {
    return 'w $folder';
  }

  @override
  String inYourLibrary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return '$_temp0 w Twojej bibliotece';
  }

  @override
  String get inactive => 'Nieaktywny';

  @override
  String get incredibleOverAMonthOfDaily =>
      'Niesamowite — ponad miesiąc codziennego słuchania.';

  @override
  String get inputGain => 'Wzmocnienie wejściowe';

  @override
  String get inst => 'Inst';

  @override
  String get instructions => 'Instrukcje';

  @override
  String get instrumental => 'Instrumentalny';

  @override
  String get interactiveEq => 'Interaktywny korektor';

  @override
  String get interfaceClaimed => 'Interfejs zgłoszony';

  @override
  String get isochronousUsb => 'Izochroniczne USB';

  @override
  String items(Object count) {
    return 'Elementy $count';
  }

  @override
  String get jan => 'styczeń';

  @override
  String get jellyfin => 'Galaretka';

  @override
  String get jellyfinEmby => 'Jellyfin · Emby';

  @override
  String get jul => 'lipiec';

  @override
  String get jumpBackIn => 'Wskocz z powrotem';

  @override
  String get jun => 'czerwca';

  @override
  String get justAudioExoplayer => 'just_audio / ExoPlayer';

  @override
  String get justAudioExoplayerDefault => 'just_audio / ExoPlayer (domyślnie)';

  @override
  String get justNow => 'Przed chwilą';

  @override
  String get karaokePreview => 'Podgląd karaoke';

  @override
  String kb(Object arg1) {
    return '$arg1 KB';
  }

  @override
  String get keepAll => 'Zachowaj wszystko';

  @override
  String get keepEditing => 'Edytuj dalej';

  @override
  String get keepItGoingOpenTomorrowTo =>
      'Kontynuuj to. Otwórz jutro, aby dodać kolejny dzień.';

  @override
  String get keepListeningWithFlick => 'Słuchaj dalej z Hadoo';

  @override
  String get keepPlaybackPausedWhenADevice =>
      'Wstrzymaj odtwarzanie, gdy urządzenie ponownie się połączy';

  @override
  String get keepTheSessionMovingOrHead =>
      'Kontynuuj sesję lub wróć od razu do gracza.';

  @override
  String get keepYourReplay => 'Zachowaj powtórkę.';

  @override
  String keeping(Object type, Object br) {
    return 'Zachowanie • $type • $br';
  }

  @override
  String keepingOfToRemove(Object keptCount, Object arg1, Object removeCount) {
    return 'Zachowanie $keptCount z $arg1 • $removeCount do usunięcia';
  }

  @override
  String get keepingThisVersion => 'Utrzymanie tej wersji';

  @override
  String get keepsSoftwareVolumeAndDspActive =>
      'Utrzymuje głośność oprogramowania i aktywny procesor DSP na współdzielonej ścieżce DAP.';

  @override
  String get keptInSecureStorageToRe =>
      'Przechowywane w bezpiecznym magazynie w celu ponownego zalogowania się po wygaśnięciu tokena';

  @override
  String keptWillBeRemoved(Object keptCount, Object removeCount) {
    return '$keptCount zachowane • $removeCount zostanie usunięte';
  }

  @override
  String khz(Object arg1) {
    return '${arg1}kHz';
  }

  @override
  String khz2(Object arg1) {
    return '$arg1 kHz';
  }

  @override
  String khzBit(Object arg1, Object arg2) {
    return '${arg1}kHz/${arg2}bit';
  }

  @override
  String khzBit2(Object arg1, Object arg2) {
    return '${arg1}kHz/${arg2}bit';
  }

  @override
  String khzBitCh(Object arg1, Object arg2, Object arg3) {
    return '${arg1}kHz / ${arg2}bit / ${arg3}ch';
  }

  @override
  String get label => 'Wytwórnia';

  @override
  String get labelOrganization => 'Etykieta / Organizacja';

  @override
  String get lastFm => 'Last.fm';

  @override
  String get lastFmConfiguration => 'Konfiguracja Last.fm';

  @override
  String get lastFmConnected => 'Last.fm Połączono';

  @override
  String get lastFmConnected2 => 'Last.fm podłączony!';

  @override
  String get lastPick => 'Ostatni wybór';

  @override
  String get lastWeek => 'Ostatni tydzień';

  @override
  String get lateNightSessions => 'Sesje późnonocne';

  @override
  String get latestArrivalsFromYourLibrary =>
      'Najnowsze pozycje z Twojej biblioteki';

  @override
  String get layered => 'Warstwowe';

  @override
  String get layoutMode => 'Tryb układu';

  @override
  String get ldac330Kbps => 'LDAC 330 kb/s';

  @override
  String get ldac660Kbps => 'LDAC 660 kb/s';

  @override
  String get ldac990Kbps => 'LDAC 990 kb/s';

  @override
  String get ldacAdaptive => 'Adaptacyjny LDAC';

  @override
  String get ldacBitsPerSample => 'Bity LDAC na próbkę';

  @override
  String get leLsbLittleEndianSubslotLsb =>
      'LE-LSB — podszczelina Little-endian, najpierw LSB';

  @override
  String get leMsbLittleEndianSubslotMsb =>
      'LE-MSB — podszczelina Little-endian, najpierw MSB';

  @override
  String get leaveEmptyToKeepTheCurrent =>
      'Pozostaw puste, aby zachować bieżące poświadczenia';

  @override
  String get leftBottom => 'Po lewej (na dole)';

  @override
  String get leftBottomButton => 'Lewy (dolny) przycisk';

  @override
  String get leftTop => 'Lewy (górny)';

  @override
  String get leftTopButton => 'Lewy (górny) przycisk';

  @override
  String get length => 'Długość:';

  @override
  String lengthS(Object arg1) {
    return 'Długość ${arg1}s';
  }

  @override
  String get letAndroidChooseTheBestCodec =>
      'Pozwól Androidowi wybrać najlepszy kodek';

  @override
  String get letAndroidChooseTheOutputDevice =>
      'Pozwól Androidowi wybrać urządzenie wyjściowe';

  @override
  String get letAndroidNegotiateTheCodecAutomatically =>
      'Pozwól Androidowi automatycznie negocjować kodek';

  @override
  String get letOboePickTheBestApi =>
      'Pozwól Oboe wybrać najlepsze API. Najpierw AAudio, potem rezerwa OpenSL ES.';

  @override
  String get letSTakeAQuickTour =>
      'Przyjrzyjmy się szybko Twojemu nowemu odtwarzaczowi muzyki.';

  @override
  String get libraryLabel => 'Biblioteka';

  @override
  String get light => 'Światło';

  @override
  String likedSongs(Object arg1) {
    return '$arg1 lubił piosenki';
  }

  @override
  String get likedSongsLiveHere => 'Tutaj znajdziesz ulubione utwory';

  @override
  String get likesAndReplaysBlendedTogether =>
      'Polubienia i powtórki połączone w jedną całość';

  @override
  String get limit => 'Limit';

  @override
  String get limiter => 'Ogranicznik';

  @override
  String get limiterOff => 'Ogranicznik wyłączony';

  @override
  String get limiterOn => 'Ogranicznik włączony';

  @override
  String get line => 'Linia';

  @override
  String lineOf(Object arg1, Object arg2) {
    return 'Linia $arg1 z $arg2';
  }

  @override
  String lineOfWords(
    Object arg1,
    Object arg2,
    Object captured,
    Object segmentCount,
  ) {
    return 'Linia $arg1 z $arg2 · $captured/$segmentCount słowa';
  }

  @override
  String get lines => 'Linie';

  @override
  String lines2(Object arg1) {
    return 'Linie $arg1';
  }

  @override
  String get linkReady => 'Link gotowy';

  @override
  String linkedToThisSong(Object arg1) {
    return 'Połączono „$arg1” z tą piosenką.';
  }

  @override
  String get list => 'Lista';

  @override
  String get listAvailableLocalAudioOutputDevices =>
      'Lista dostępnych lokalnych urządzeń wyjściowych audio';

  @override
  String get listenbrainz => 'ListenBrainz';

  @override
  String get listenbrainzConnected => 'ListenBrainz Połączono';

  @override
  String get listenbrainzConnected2 => 'ListenBrainz podłączony!';

  @override
  String get listeningHours => 'Godziny słuchania';

  @override
  String listeningToByOnFlick(Object arg1, Object arg2) {
    return 'Słuchanie $arg1 autorstwa $arg2 na Hadoo';
  }

  @override
  String get littleEndianSubslotLsbFirstBits =>
      'Podszczelina Little-endian, pierwsze bity LSB';

  @override
  String get littleEndianSubslotMsbFirstBits =>
      'Podszczelina Little-endian, pierwsze bity MSB';

  @override
  String get livePreview => 'Podgląd na żywo';

  @override
  String get livingOrnament => 'Żywa ozdoba';

  @override
  String get loadAJsonOrTxtPreset => 'Załaduj ustawienie wstępne JSON lub TXT';

  @override
  String get loadAnImpulseResponseForRoom =>
      'Załaduj odpowiedź impulsową dla pogłosu pomieszczenia, crossfeedu, kolumny lub korekcji.';

  @override
  String get loadIr => 'Załaduj podczerwień';

  @override
  String loadedIr(Object displayName) {
    return 'Załadowany IR: $displayName';
  }

  @override
  String get loadingArtwork2 => 'Ładowanie grafiki…';

  @override
  String get loadingFavoritesRecentSessionsGenerated =>
      'Ładowanie ulubionych, ostatnich sesji, wygenerowanych miksów i list odtwarzania.';

  @override
  String get loadingReplay => 'Ładowanie powtórki';

  @override
  String get loadingSession => 'Ładowanie sesji...';

  @override
  String get locked => 'Zablokowane';

  @override
  String get logFrequencyControl => 'Kontrola częstotliwości logu';

  @override
  String get logs => 'Dzienniki';

  @override
  String get logsCopied => 'Logi skopiowane';

  @override
  String get longSongTitles => 'Długie tytuły piosenek';

  @override
  String get look => 'Spójrz';

  @override
  String get lookingForCoverArtFromMusicbrainz =>
      'Poszukuję okładek z MusicBrainz i Archiwum okładek.';

  @override
  String get lossless => ' Bezstratny';

  @override
  String get losslessQualityPreservedDuringConversion =>
      'Bezstratna jakość zachowana podczas konwersji';

  @override
  String get lowAndHighFrequenciesScoopedMids =>
      'Niskie i wysokie częstotliwości, wzmocniona średnica';

  @override
  String get lowFrequenciesOnly => 'Tylko niskie częstotliwości';

  @override
  String get lowLatencyGoodQuality => 'Niskie opóźnienia, dobra jakość';

  @override
  String get lowLatencyMode => 'Tryb małego opóźnienia';

  @override
  String get lowPass => 'Niskoprzepustowy';

  @override
  String get lowShelf => 'Niska półka';

  @override
  String get lrclib => 'LRCLib';

  @override
  String get lyric => 'Liryczny';

  @override
  String get lyrics => 'Tekst utworu';

  @override
  String get lyricsPreview => 'Podgląd tekstu';

  @override
  String get lyricsSavedFromLrclib => 'Teksty zapisane z LRCLib.';

  @override
  String get lyricsSyncHelp => 'Pomoc dotycząca synchronizacji tekstów';

  @override
  String get lyricsSyncStudio => 'Studio synchronizacji tekstów';

  @override
  String get lyricsText => 'Tekst piosenki';

  @override
  String m(Object arg1) {
    return '${arg1}m';
  }

  @override
  String m2(Object arg1) {
    return '${arg1}m';
  }

  @override
  String mAgo(Object arg1) {
    return '${arg1}m temu';
  }

  @override
  String get madeForYou => 'Stworzone dla Ciebie';

  @override
  String get makeup => 'Makijaż';

  @override
  String get manualOrder => 'Zamówienie ręczne';

  @override
  String get manualQueue => 'Ręczna kolejka';

  @override
  String get manufacturer => 'Producent';

  @override
  String get mar => 'marca';

  @override
  String get masterBypassed => 'Mistrz ominął';

  @override
  String matchByArtistAlbumAndTrack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pliki $count',
      one: 'Plik $count',
    );
    return 'Mecz $_temp0 według artysty, albumu i długości utworu';
  }

  @override
  String get matchEqToYourHeadphoneModel =>
      'Dopasuj EQ do swojego modelu słuchawek';

  @override
  String get matchNavigation => 'Dopasuj nawigację';

  @override
  String get matches => 'Mecze';

  @override
  String maxB(Object arg1) {
    return 'Max $arg1 B';
  }

  @override
  String get maximumAudioQuality => 'Maksymalna jakość dźwięku';

  @override
  String get may => 'Maj';

  @override
  String mb(Object arg1) {
    return '${arg1}MB';
  }

  @override
  String get medium => 'Średni';

  @override
  String get menu => 'Menu';

  @override
  String get metropolitan => 'Metropolita';

  @override
  String mhz(Object arg1) {
    return '$arg1 MHz';
  }

  @override
  String get mid => 'Środek';

  @override
  String get midFrequenciesOnly => 'Tylko średnie częstotliwości';

  @override
  String get midnightCityDreams => 'Sny o północnym mieście';

  @override
  String get midnightSignal => 'Sygnał północy';

  @override
  String get milestone => 'Kamień milowy';

  @override
  String get milestones => 'Kamienie milowe';

  @override
  String min(Object arg1) {
    return '$arg1 min';
  }

  @override
  String get miniPlayer => 'Miniodtwarzacz';

  @override
  String get miniPlayerAppearance => 'Wygląd miniodtwarzacza';

  @override
  String get miniPlayerDefaultsRestored =>
      'Przywrócono domyślne ustawienia miniodtwarzacza';

  @override
  String get miniPlayerHeight => 'Wysokość miniodtwarzacza';

  @override
  String get miniPlayerLayout => 'Układ miniodtwarzacza';

  @override
  String get minimal => 'Minimalne';

  @override
  String get minimserverServiioKodi => 'MinimServer · Serviio · Kodi';

  @override
  String get mirrorTest => 'Próba lustra';

  @override
  String get mirrored => 'Lustrzane';

  @override
  String get mitLicenseCopyrightC2026Flick =>
      '\nLicencja MIT\n\nPrawa autorskie (c) 2026 Flick Współtwórcy graczy\n\nZezwolenie udzielane jest bezpłatnie każdej osobie otrzymującej kopię\ntego oprogramowania i powiązanych plików dokumentacji („Oprogramowanie”)\nw Oprogramowaniu bez ograniczeń, w tym bez ograniczeń praw\nużywać, kopiować, modyfikować, łączyć, publikować, rozpowszechniać, udzielać sublicencji i/lub sprzedawać\nkopii Oprogramowania oraz zezwalania osobom, do których Oprogramowanie jest przeznaczone\ndo tego przygotowany, z zastrzeżeniem następujących warunków:\n\nPowyższa informacja o prawach autorskich i niniejsza informacja o zezwoleniu zostaną dołączone do całości\nkopie lub istotne części Oprogramowania.\n\nOPROGRAMOWANIE JEST DOSTARCZANE „TAKIE, JAKIE JEST”, BEZ ŻADNYCH GWARANCJI, WYRAŹNYCH LUB\nDOROZUMIANYCH, W TYM M.in. GWARANCJI WARTOŚCI HANDLOWEJ,\nPRZYDATNOŚĆ DO OKREŚLONEGO CELU I NIENARUSZANIE. W ŻADNYM WYPADKU\nAUTORZY LUB WŁAŚCICIELE PRAW AUTORSKICH PONOSZĄ ODPOWIEDZIALNOŚĆ ZA WSZELKIE ROSZCZENIA, SZKODY LUB INNE\nODPOWIEDZIALNOŚĆ WYNIKAJĄCA Z CZYNNOŚCI UMOWNEJ, DELIKTUJNEJ LUB INNEJ, WYNIKAJĄCEJ Z:\nPOZA LUB W ZWIĄZKU Z OPROGRAMOWANIEM LUB WYKORZYSTANIEM LUB INNYMI TRANSAKCJAMI ZWIĄZANYMI Z OPROGRAMOWANIEM\nOPROGRAMOWANIE.\n';

  @override
  String get mix => 'Mieszać';

  @override
  String mix2(Object arg1) {
    return 'Wymieszaj $arg1';
  }

  @override
  String get mixer => 'Mikser';

  @override
  String get mixerManagement => 'Zarządzanie mikserem';

  @override
  String moAgo(Object arg1) {
    return '${arg1}mo temu';
  }

  @override
  String get moderate => 'Umiarkowany';

  @override
  String get mono => 'Mononukleoza';

  @override
  String get monthly => 'Miesięczny';

  @override
  String get more => 'Więcej';

  @override
  String more2(Object arg1, Object arg2) {
    return '$arg1 + $arg2 więcej';
  }

  @override
  String get moreActions => 'Więcej akcji';

  @override
  String get moreArtists => 'Więcej artystów';

  @override
  String get moreArtists2 => 'Więcej artystów';

  @override
  String get moreExportOptions => 'Więcej opcji eksportu';

  @override
  String moreFrom(Object arg1) {
    return 'Więcej z $arg1';
  }

  @override
  String get moreFromArtist => 'Więcej od artysty';

  @override
  String moreTo(Object arg1, Object arg2) {
    return '$arg1 więcej do $arg2';
  }

  @override
  String moreToUnlock(Object remaining, Object unit) {
    return '$remaining więcej $unit do odblokowania.';
  }

  @override
  String get mostDlnaServersNeedNoPassword =>
      'Większość serwerów DLNA nie potrzebuje hasła';

  @override
  String get mostPlayed => 'Najczęściej odtwarzane';

  @override
  String mostReplayed(Object arg1) {
    return 'Najczęściej odtwarzane · $arg1';
  }

  @override
  String get motionArtRefreshed => 'Odświeżona grafika ruchoma';

  @override
  String get moveEveryStampedLyricForwardOr =>
      'Przesuwaj każdy wytłoczony tekst razem do przodu lub do tyłu.';

  @override
  String get movement => 'Ruch';

  @override
  String ms(Object arg1) {
    return '$arg1 ms';
  }

  @override
  String ms2(Object arg1) {
    return '$arg1 ms';
  }

  @override
  String ms3(Object arg1) {
    return '$arg1 ms';
  }

  @override
  String ms4(Object arg1) {
    return '$arg1 ms';
  }

  @override
  String ms5(Object arg1) {
    return '$arg1 ms';
  }

  @override
  String get multiFilterBands => 'Pasma wielofiltrowe';

  @override
  String musicFolders(Object arg1) {
    return 'Foldery muzyczne $arg1';
  }

  @override
  String get mute => 'Niemy';

  @override
  String my(Object arg1) {
    return 'Mój $arg1';
  }

  @override
  String nDb(Object arg1, Object arg2) {
    return '$arg1%\n$arg2 dB';
  }

  @override
  String get nameAZ => 'Imię (A-Z)';

  @override
  String narrow(Object amount) {
    return '$amount% wąskie';
  }

  @override
  String get nativeDsd => 'Natywny DSD';

  @override
  String get nativeDsdExperimental => 'Natywny DSD (eksperymentalny)';

  @override
  String get nativeDsdExperimentalMayBeBuggy =>
      'Natywny DSD — eksperymentalny (może zawierać błędy)';

  @override
  String get naturalEqualizerFeelResponsiveYetSmooth =>
      'Naturalne wyczucie korektora — responsywne, a jednocześnie gładkie';

  @override
  String get natureAmbient => 'Otoczenie natury';

  @override
  String get navidromeAirsonicGonic => 'Navidrome · Airsonic · Gonic';

  @override
  String get navigationBar => 'Pasek nawigacji';

  @override
  String get needsMetadata => 'Potrzebuje metadanych';

  @override
  String negotiated(Object arg1) {
    return 'Negocjowano: $arg1';
  }

  @override
  String get neonNights => 'Neonowe noce';

  @override
  String get neonSkyline => 'Neonowa linia horyzontu';

  @override
  String get network => 'Sieć';

  @override
  String get networkSources => 'Źródła sieciowe';

  @override
  String neutral(Object amount) {
    return '$amount% neutralny';
  }

  @override
  String get neverSynced => 'Nigdy nie synchronizowano';

  @override
  String get next => 'Następny';

  @override
  String get nextSong => 'Następna piosenka';

  @override
  String get nextSong2 => 'Następna piosenka';

  @override
  String nextToGo(Object arg1, Object remaining, Object unit) {
    return 'Dalej: $arg1 — $remaining $unit i gotowe';
  }

  @override
  String get nextcloudOwncloudSabredav => 'Nextcloud · ownCloud · SabreDAV';

  @override
  String get night => 'Noc';

  @override
  String get no => 'Nie';

  @override
  String get noAlbumDataYet => 'Nie ma jeszcze danych albumu';

  @override
  String get noAlbumsFound => 'Nie znaleziono albumów';

  @override
  String get noAppleMusicReleaseFoundTry =>
      'Nie znaleziono wersji Apple Music. Spróbuj edytować nazwę wykonawcy lub albumu i wyszukaj ponownie.';

  @override
  String get noArtistsFound => 'Nie znaleziono artystów';

  @override
  String noArtistsMatch(Object _searchQuery) {
    return 'Żaden artysta nie pasuje do „$_searchQuery”';
  }

  @override
  String get noCastingDevicesFoundMakeSure =>
      'Nie znaleziono urządzeń przesyłających. Upewnij się, że telefon i odbiornik znajdują się w tej samej sieci.';

  @override
  String get noCategoriesSelected => 'Nie wybrano kategorii';

  @override
  String get noChangelogNotesForThisVersion =>
      'Nie ma jeszcze żadnych notatek do dziennika zmian dla tej wersji.';

  @override
  String get noCustomPresetsYet =>
      'Nie ma jeszcze żadnych niestandardowych ustawień wstępnych.';

  @override
  String get noDuplicatesFound => 'Nie znaleziono duplikatów';

  @override
  String get noFavoritesYet => 'Nie ma jeszcze ulubionych';

  @override
  String get noFeaturedTrackYet => 'Nie ma jeszcze polecanego utworu';

  @override
  String get noFoldersAdded => 'Nie dodano żadnych folderów';

  @override
  String get noHistoryYet => 'Nie ma jeszcze historii';

  @override
  String get noInternetConnectionPleaseCheckYour =>
      'Brak połączenia z Internetem. Sprawdź swoją sieć i spróbuj ponownie.';

  @override
  String get noLogsYet => 'Nie ma jeszcze żadnych logów.';

  @override
  String get noLyricsFoundOnlineForThis =>
      'W Internecie nie znaleziono tekstu tej piosenki.';

  @override
  String get noLyricsYet => 'Nie ma jeszcze tekstu';

  @override
  String get noMatchFound => 'Nie znaleziono dopasowania';

  @override
  String get noMatches => 'Brak dopasowań.';

  @override
  String noMatchesFor(Object _query) {
    return 'Brak dopasowań dla „$_query”';
  }

  @override
  String get noMatchesFound => 'Nie znaleziono żadnych dopasowań';

  @override
  String get noMatchesTryFewerWordsOr =>
      'Brak dopasowań. Spróbuj użyć mniejszej liczby słów lub wyszukaj online.';

  @override
  String get noMusicYet => 'Jeszcze nie ma muzyki';

  @override
  String get noNewAdditionsYet => 'Nie ma jeszcze żadnych nowych dodatków';

  @override
  String get noOnlineArtworkFound => 'Nie znaleziono dzieł sztuki online';

  @override
  String get noOutputDevicesAvailable =>
      'Brak dostępnych urządzeń wyjściowych.';

  @override
  String get noPlaybackYet => 'Nie ma jeszcze odtwarzania';

  @override
  String get noPlaylistsYet => 'Nie ma jeszcze playlist';

  @override
  String get noPlaylistsYet2 => 'Nie ma jeszcze playlist';

  @override
  String get noPlaylistsYetNcreateOneIn =>
      'Nie ma jeszcze list odtwarzania.\nUtwórz ją na karcie Listy odtwarzania.';

  @override
  String get noRankingDataYet => 'Nie ma jeszcze danych rankingowych';

  @override
  String noResultsFor(Object query) {
    return 'Brak wyników dla „$query”';
  }

  @override
  String noResultsFoundFor(Object query) {
    return 'Nie znaleziono żadnych wyników dla \"$query\".';
  }

  @override
  String get noRipData => 'Brak danych zgrywania';

  @override
  String get noScanResultsYet => 'Nie ma jeszcze wyników skanowania';

  @override
  String get noServerPlaylistsFound => 'Nie znaleziono playlist serwera';

  @override
  String get noServersConnected => 'Brak podłączonych serwerów';

  @override
  String get noSongPlaying => 'Brak odtwarzania utworu';

  @override
  String get noSongsFound => 'Nie znaleziono utworów';

  @override
  String get noSongsInThisPlaylist => 'Brak utworów na tej liście odtwarzania';

  @override
  String get noUpcomingQueueItemsYet =>
      'Nie ma jeszcze żadnych nadchodzących elementów w kolejce.';

  @override
  String get noUrbData => 'Brak danych URB';

  @override
  String get noUsbAudioDevicesFound => 'Nie znaleziono urządzeń audio USB';

  @override
  String get noWordTimingYetAutoFill =>
      'Nie ma jeszcze terminu na słowa. Funkcja automatycznego wypełniania równomiernie rozprowadza wyrazy jako punkt wyjścia — lub przechwytuje je w trybie synchronizacji programu Word.';

  @override
  String get none => 'Brak';

  @override
  String get notAnAlacFile => 'To nie jest plik ALAC';

  @override
  String get notFoundOnlineTryADifferent =>
      'Nie znaleziono w Internecie. Spróbuj innej pisowni.';

  @override
  String get notHeld => 'Nie trzymany';

  @override
  String get notRecommendedForNormalUsageDsd =>
      'Nie zaleca się do normalnego użytkowania. Odtwarzanie DSD jest niestabilne i może powodować zakłócenia dźwięku.';

  @override
  String get notRegistered => 'Niezarejestrowany';

  @override
  String get notSet => 'Nie ustawiono';

  @override
  String get notStampedYet => 'Jeszcze nie stemplowane';

  @override
  String get notVerified => 'Niezweryfikowano';

  @override
  String get notch => 'Wycięcie';

  @override
  String get notchDepth => 'Głębokość wycięcia';

  @override
  String get noticeableTintingFromAlbumArt =>
      'Zauważalne zabarwienie wynikające z okładek albumów.';

  @override
  String get nov => 'listopad';

  @override
  String get now => 'Teraz';

  @override
  String get nowPlaying => 'Teraz odtwarzane';

  @override
  String get nowPlaying2 => 'Teraz odtwarzane';

  @override
  String get numberOnArt => 'Numer w art';

  @override
  String get oauthSignInNoPasswordStored =>
      'logowanie OAuth; nie ma tutaj zapisanego hasła';

  @override
  String get oceanWaves => 'Fale Oceanu';

  @override
  String get oct => 'paź';

  @override
  String get off => 'Wył.';

  @override
  String get onAndroidTheStandardJustAudio =>
      'W systemie Android standardowa ścieżka odtwarzania just_audio stosuje teraz natywne odpowiedniki korektora, dynamiki, balansu i efektów przestrzennych na obsługiwanych urządzeniach. Silnik Rust nadal zapewnia najdokładniejszą wersję tych elementów sterujących, więc niektóre wyniki dla Androida są przybliżone.';

  @override
  String get onRepeat => 'Na powtórzeniu';

  @override
  String get onlineResults => 'Wyniki online';

  @override
  String get onlyLibraryEntriesAreRemovedYour =>
      'Usuwane są tylko wpisy biblioteki — pliki audio pozostają na dysku.';

  @override
  String get open => 'Otwórz';

  @override
  String get openAndroidSettings => 'Otwórz ustawienia Androida';

  @override
  String get openBluetoothCodecSettings => 'Otwórz Ustawienia kodeka Bluetooth';

  @override
  String get openInAppleMusic => 'Otwórz w Apple Music';

  @override
  String get openInBrowser => 'Otwórz w przeglądarce';

  @override
  String get openLibrary => 'Otwórz bibliotekę';

  @override
  String get openListenbrainzOrgSettings =>
      'Otwórz stronę Listenbrainz.org/settings';

  @override
  String get openManual => 'Otwórz podręcznik';

  @override
  String get openPlayer => 'Otwórz odtwarzacz';

  @override
  String get openedFromLocker => 'Otwarte z szafki';

  @override
  String get openslEs => 'OpenSL ES';

  @override
  String get openslEsLegacy => 'OpenSL ES (starsza wersja)';

  @override
  String get orRemoveAllUsingRecommendedPicks =>
      'Lub usuń wszystkie, korzystając z zalecanych typów';

  @override
  String get orbital => 'Orbitalny';

  @override
  String get otherPlaylists => 'Inne playlisty';

  @override
  String get ourRustPoweredEngineCleanerSound =>
      'Nasz silnik napędzany rdzą. Czystszy dźwięk i płynniejsze odtwarzanie — zalecane do codziennego słuchania.';

  @override
  String get outlineTheMiniPlayer => 'Nakreśl miniodtwarzacz';

  @override
  String get output => 'Wyjście';

  @override
  String get outputDevice => 'Urządzenie wyjściowe';

  @override
  String get outputMode => 'Tryb wyjściowy';

  @override
  String get outputRate => 'Szybkość wyjściowa';

  @override
  String get overviewMetricsChooseUpTo3 =>
      'Przegląd wskaźników · wybierz maksymalnie 3';

  @override
  String get paired => 'Sparowane';

  @override
  String get parametric => 'Parametryczny';

  @override
  String parametricBandsWithIndependentFrequency(Object arg1) {
    return 'Pasma parametryczne $arg1 z niezależną częstotliwością, wzmocnieniem i kształtowaniem Q. Kliknij, aby wejść w interakcję.';
  }

  @override
  String get parametricEq => 'Korektor parametryczny';

  @override
  String get passthrough => 'Przejście';

  @override
  String get password => 'Hasło';

  @override
  String get pasteOrTypeTheSongLyrics =>
      'Wklej lub wpisz tutaj tekst piosenki — po jednym wierszu w wierszu';

  @override
  String get pasteYourListenbrainzToken => 'Wklej swój token ListenBrainz';

  @override
  String get pause => 'Wstrzymaj';

  @override
  String get pauseOnBluetoothConnect => 'Wstrzymaj połączenie Bluetooth';

  @override
  String get pauseOnDisconnect => 'Wstrzymaj po rozłączeniu';

  @override
  String get pauseOnUsbDacAttach => 'Wstrzymaj przy podłączaniu USB DAC';

  @override
  String get pauseOnUsbDacDetach => 'Wstrzymaj na USB DAC Odłącz';

  @override
  String get pcmFrames => 'Ramki PCM';

  @override
  String get peakHour => 'Godzina szczytu';

  @override
  String get peaking => 'Szczyt';

  @override
  String get permission => 'Pozwolenie';

  @override
  String get personalPlaylist => 'Osobista playlista';

  @override
  String get phoneAndHeadsetVolumeAreIndependent =>
      'Głośność telefonu i zestawu słuchawkowego jest niezależna';

  @override
  String get phoneAndHeadsetVolumeAreLinked =>
      'Głośność telefonu i zestawu słuchawkowego jest powiązana';

  @override
  String get photoFraming => 'Kadrowanie zdjęć';

  @override
  String get pickALineWithLyrics => 'Wybierz wiersz z tekstem';

  @override
  String get pickALyricLineIn =>
      '1. Wybierz wiersz tekstu w wierszu Linie, a następnie przejdź do pliku Tools.\n2. Naciśnij przycisk odtwarzania i dotknij dużego przycisku „Dotknij słowa”, gdy usłyszysz każde słowo — pierwsze dotknięcie również oznacza linię.\n3. Stuknij element słowny, aby go szturchnąć, zmienić czas lub wyczyścić.\n4. Linie z każdym wytłoczonym słowem są zapisywane z synchronizacją karaoke dla każdego słowa.';

  @override
  String get pickAgain => 'Wybierz ponownie';

  @override
  String get pickImage => 'Wybierz obraz';

  @override
  String get pickUpExactlyWhereYourLast =>
      'Rozpocznij dokładnie w miejscu, w którym zakończyły się Twoje ostatnie sesje.';

  @override
  String get pinchApartNarrowerHigherQNpinch =>
      'Rozsuń = węższy (wyższe Q) \n Zsuń razem = szerszy (niższy Q)';

  @override
  String get pitch => 'Skok';

  @override
  String pitchSemitones(int semitones) {
    String _temp0 = intl.Intl.pluralLogic(
      semitones,
      locale: localeName,
      other: 'Półtony $semitones',
      one: 'Półton $semitones',
    );
    return '$_temp0';
  }

  @override
  String get plain => 'Zwykły';

  @override
  String get plainText => 'Zwykły tekst';

  @override
  String get play => 'Odtwórz';

  @override
  String get playAFewSongsAndThis =>
      'Odtwórz kilka utworów, a ta strona zacznie się zapełniać miksami, wykonawcami i skrótami.';

  @override
  String get playAFewTracksTodayTo =>
      'Odtwórz dzisiaj kilka utworów, aby stworzyć codzienne podsumowanie.';

  @override
  String get playAgain => 'Zagraj ponownie';

  @override
  String get playBadges => 'Graj w odznaki';

  @override
  String get playCategoriesInRandomOrderTracks =>
      'Odtwarzaj kategorie w kolejności losowej, utwory po kolei';

  @override
  String get playInOrder => 'Graj w kolejności';

  @override
  String get playNext => 'Odtwórz jako następne';

  @override
  String get playbackContinuesWhenABluetoothDevice =>
      'Odtwarzanie będzie kontynuowane po podłączeniu urządzenia Bluetooth';

  @override
  String get playbackContinuesWhenAUsbDac =>
      'Odtwarzanie jest kontynuowane po podłączeniu przetwornika cyfrowo-analogowego USB';

  @override
  String get playbackContinuesWhenAUsbDac2 =>
      'Odtwarzanie jest kontynuowane po odłączeniu przetwornika cyfrowo-analogowego USB';

  @override
  String get playbackContinuesWhenAudioOutput =>
      'Odtwarzanie jest kontynuowane po odłączeniu wyjścia audio';

  @override
  String get playbackEngine => 'Silnik odtwarzania';

  @override
  String get playbackIsUsingAndroidManagedOutput =>
      'Odtwarzanie wykorzystuje dane wyjściowe zarządzane przez system Android i może zostać ponownie próbkowane.';

  @override
  String get playbackIsUsingTheStandardAndroid =>
      'Odtwarzanie odbywa się przy użyciu standardowej ścieżki wyjściowej systemu Android.';

  @override
  String get playbackModeWillUpdateAfterThe =>
      'Tryb odtwarzania zostanie zaktualizowany po następnej trasie lub odświeżeniu odtwarzania.';

  @override
  String get playbackPath => 'Ścieżka odtwarzania';

  @override
  String get playbackPausesWhenABluetoothAudio =>
      'Odtwarzanie zostaje wstrzymane po podłączeniu urządzenia audio Bluetooth';

  @override
  String get playbackPausesWhenAUsbDac =>
      'Odtwarzanie zostaje wstrzymane po podłączeniu przetwornika cyfrowo-analogowego USB';

  @override
  String get playbackPausesWhenAUsbDac2 =>
      'Odtwarzanie zostaje wstrzymane po fizycznym odłączeniu przetwornika cyfrowo-analogowego USB';

  @override
  String get playbackPausesWhenBluetoothOrHeadphones =>
      'Odtwarzanie zostaje wstrzymane po odłączeniu Bluetooth lub słuchawek';

  @override
  String get playbackResumesWhenADeviceReconnects =>
      'Odtwarzanie zostanie wznowione, gdy urządzenie ponownie połączy się w ciągu 30 sekund';

  @override
  String get playbackSpeed => 'Szybkość odtwarzania';

  @override
  String played(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return '$_temp0 grał';
  }

  @override
  String get playerLayout => 'Układ gracza';

  @override
  String playlist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listy odtwarzania $count',
      one: 'Playlista $count',
    );
    return '$_temp0';
  }

  @override
  String get playlist2 => 'Playlista';

  @override
  String playlistCreated(Object arg1) {
    return 'Utworzono playlistę „$arg1”.';
  }

  @override
  String get playlistName => 'Nazwa playlisty';

  @override
  String get playlists => 'Playlisty';

  @override
  String plays(Object arg1) {
    return '$arg1 gra';
  }

  @override
  String plays2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gra',
      one: '1 sztuka',
    );
    return '$_temp0';
  }

  @override
  String get playsInRotation => 'gra na zmianę';

  @override
  String get pleaseEnterAPlaylistName => 'Wpisz nazwę playlisty';

  @override
  String get pleaseEnterYourListenbrainzUserToken =>
      'Proszę wprowadzić token użytkownika ListenBrainz.';

  @override
  String posterPreviewPlays(Object arg1, Object arg2) {
    return 'Podgląd plakatu $arg1. $arg2 gra.';
  }

  @override
  String get preamp => 'Przedwzmacniacz';

  @override
  String get preloadingAudio3 => 'Wstępne ładowanie dźwięku';

  @override
  String get preparing => 'Przygotowanie…';

  @override
  String get presence => 'Obecność';

  @override
  String preset(Object activePresetName) {
    return 'Ustawienie wstępne: $activePresetName';
  }

  @override
  String get presetImportedWithAdjustments =>
      'Preset zaimportowany z korektami';

  @override
  String get presetName => 'Zaprogramowana nazwa';

  @override
  String get presets => 'Ustawienia wstępne';

  @override
  String get preview => 'Podgląd';

  @override
  String get previewUse => 'Podgląd i użycie';

  @override
  String get previousSong => 'Poprzednia piosenka';

  @override
  String get previousSong2 => 'Poprzedni utwór';

  @override
  String get prewarming => 'Wstępne rozgrzewanie';

  @override
  String get prioritiseConnectionStability =>
      'Nadaj priorytet stabilności połączenia';

  @override
  String get processingLive => 'Przetwarzanie na żywo';

  @override
  String get product => 'Produkt';

  @override
  String get productId => 'Identyfikator produktu';

  @override
  String get progress => 'Postęp';

  @override
  String get protocol => 'Protokół';

  @override
  String get pulledFromYourLateSessionPlays =>
      'Wyciągnięte z twoich przedstawień z późnych sesji';

  @override
  String get purple => 'Fioletowy';

  @override
  String get queue => 'Kolejka';

  @override
  String queue2(Object count) {
    return 'Kolejka $count';
  }

  @override
  String get queueIsEmpty => 'Kolejka jest pusta';

  @override
  String queued(Object arg1) {
    return 'W kolejce „$arg1”';
  }

  @override
  String queuedSongs(Object arg1) {
    return 'Ustawione w kolejce utwory $arg1';
  }

  @override
  String queuedSongs3(Object arg1) {
    return 'Ustawione w kolejce utwory $arg1';
  }

  @override
  String get quickActions => 'Szybkie działania';

  @override
  String get random => 'Losowe';

  @override
  String get rating => 'Ocena';

  @override
  String get ratio => 'Stosunek';

  @override
  String get rawDsdStreamToDacRequires =>
      'Surowy strumień DSD do DAC. Wymaga obsługi sprzętu ENCODING_DSD; w przeciwnym razie automatycznie powraca do DoP lub PCM.';

  @override
  String get rawPcm => '→ Surowy PCM';

  @override
  String get readMode => 'Tryb czytania';

  @override
  String get readingTheCoverColors => 'Czytając kolory okładek…';

  @override
  String readyToRemoveSongKeepingIn(int count, Object kept) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return 'Gotowe do usunięcia $_temp0 — zachowując łącznie $kept.';
  }

  @override
  String recapSavedAs(Object format) {
    return 'Podsumowanie zapisane jako $format';
  }

  @override
  String recentPicksOnHand(Object arg1) {
    return '$arg1 najnowsze typy pod ręką';
  }

  @override
  String get recentlyAdded => 'Ostatnio dodane';

  @override
  String get recentlyAddedTracksWaitingForMore =>
      'Ostatnio dodane utwory czekają na dłuższy czas odtwarzania.';

  @override
  String get recentlyPlayed => 'Ostatnio odtwarzane';

  @override
  String get recommended => 'Zalecane';

  @override
  String get recommendedOnly => 'Tylko zalecane';

  @override
  String get reconnectAttempts => 'Próby ponownego połączenia';

  @override
  String get reconnectNow => 'Połącz się ponownie teraz';

  @override
  String get reconnectionFailed => 'Ponowne połączenie nie powiodło się';

  @override
  String get reconnectionSuccessful => 'Ponowne połączenie powiodło się';

  @override
  String get recorded => 'Nagrano';

  @override
  String get refreshAppleMusic => 'Odśwież Apple Music';

  @override
  String get refreshDevices => 'Odśwież urządzenia';

  @override
  String get refreshDevices2 => 'Odśwież urządzenia';

  @override
  String get refreshMotionArt => 'Odśwież grafikę ruchomą';

  @override
  String get refreshOutputs => 'Odśwież wyniki';

  @override
  String get refreshingAppleMusicData => 'Odświeżanie danych Apple Music';

  @override
  String get registeredNotClaimed => 'Zarejestrowany, nie reklamowany';

  @override
  String get reinitializingPlayback => 'Ponowna inicjalizacja odtwarzania…';

  @override
  String get release => 'Wydanie';

  @override
  String get remove => 'Usuń';

  @override
  String get removeAll => 'Usuń wszystkie';

  @override
  String get removeAllWithBestPicks => 'Usunąć wszystkie z najlepszymi typami?';

  @override
  String get removeCustomArt => 'Usuń grafikę niestandardową';

  @override
  String removeDuplicates2(Object toRemove) {
    return 'Usunąć duplikaty $toRemove?';
  }

  @override
  String removeDuplicates3(Object toRemove) {
    return 'Usuń duplikaty $toRemove';
  }

  @override
  String get removeFromFavorites => 'Usuń z ulubionych';

  @override
  String get removeFromFavorites2 => 'Usuń z ulubionych';

  @override
  String get removeFromLibrary => 'Usuń z biblioteki';

  @override
  String get removeFromPlaylist => 'Usuń z listy odtwarzania';

  @override
  String get removeSelected => 'Usuń wybrane';

  @override
  String get removeServer => 'Usunąć serwer?';

  @override
  String get removeServer2 => 'Usuń serwer';

  @override
  String get removeTheDatabaseEntriesOrDelete =>
      'Usuń wpisy z bazy danych lub usuń pliki ze swojego urządzenia. Tego nie można cofnąć.';

  @override
  String get removeTheDatabaseEntryOrDelete =>
      'Usuń wpis z bazy danych lub usuń plik ze swojego urządzenia. Tego nie można cofnąć.';

  @override
  String get removeTheseSongsFromYourLibrary =>
      'Usuń te utwory ze swojej biblioteki. Nie będzie to miało wpływu na pliki na Twoim urządzeniu.';

  @override
  String get removeThisSongFromYourLibrary =>
      'Usuń ten utwór ze swojej biblioteki. Nie będzie to miało wpływu na plik na Twoim urządzeniu.';

  @override
  String removedCustomAlbumArtFor(Object arg1) {
    return 'Usunięto niestandardową okładkę albumu dla „$arg1”.';
  }

  @override
  String removedCustomAlbumArtFor2(Object arg1) {
    return 'Usunięto niestandardową okładkę albumu dla „$arg1”.';
  }

  @override
  String removedDuplicatesKept(Object arg1, Object arg2) {
    return 'Usunięto duplikaty $arg1 — zachowano $arg2.';
  }

  @override
  String removedFromFavorites(Object arg1) {
    return 'Usunięto „$arg1” z ulubionych';
  }

  @override
  String removedFromFavorites2(Object arg1) {
    return 'Usunięto $arg1 z ulubionych';
  }

  @override
  String get removedFromFavorites3 => 'Usunięto z ulubionych';

  @override
  String removedFromLibrary(Object arg1) {
    return 'Usunięto „$arg1” z biblioteki';
  }

  @override
  String removedSongsFromFavorites(Object arg1) {
    return 'Usunięto utwory $arg1 z ulubionych';
  }

  @override
  String removedSongsFromLibrary(Object arg1) {
    return 'Usunięto utwory $arg1 z biblioteki';
  }

  @override
  String get removing => 'Usuwanie…';

  @override
  String get removingDuplicates => 'Usuwanie duplikatów…';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get renamePreset => 'Zmień nazwę ustawienia wstępnego';

  @override
  String get reorderFilterAndShuffleFromThis =>
      'Zmień kolejność, filtruj i losuj z tego nagłówka.';

  @override
  String repeat(Object arg1) {
    return 'Powtórz: $arg1';
  }

  @override
  String get repeatMode => 'Tryb powtarzania';

  @override
  String get repeatRewind => 'Powtórz przewijanie';

  @override
  String get replaceAlbumNameWithAVerified =>
      'Zastąp nazwę albumu zweryfikowaną kapsułą bit-perfect podczas przesyłania strumieniowego bit-perfect';

  @override
  String get replay => 'Odtwórz ponownie';

  @override
  String get replayCouldnTLoad => 'Nie udało się wczytać powtórki.';

  @override
  String get replayStudio => 'Studio powtórek';

  @override
  String get reportedOutputRate => 'Zgłoszona szybkość wyjściowa';

  @override
  String get requestedOutputRate => 'Żądana szybkość wyjściowa';

  @override
  String get requiredToDetectDevicesCodecsAnd =>
      'Wymagane do wykrywania urządzeń, kodeków i poziomu baterii';

  @override
  String get resampler => 'Resampler';

  @override
  String get reset => 'Resetuj';

  @override
  String get resetArtwork => 'Zresetuj grafikę';

  @override
  String get resetArtworkDescription =>
      'Ponownie wykryć grafikę z plików tego albumu? Automatycznie wykryte okładki są zastępowane grafiką odczytaną z plików; zachowana jest niestandardowa grafika.';

  @override
  String resetArtworkFor(Object arg1) {
    return 'Zresetuj grafikę dla „$arg1”.';
  }

  @override
  String resetArtworkFor2(Object arg1) {
    return 'Zresetuj grafikę dla „$arg1”.';
  }

  @override
  String get resetCardDesign => 'Zresetuj projekt karty';

  @override
  String get resetDeclinedUsbDacs => 'Zresetuj odrzucone przetworniki DAC USB';

  @override
  String get resetDynamics => 'Zresetuj dynamikę';

  @override
  String get resetFx => 'Zresetuj efekty';

  @override
  String get resetMiniPlayerToDefaults =>
      'Zresetuj Mini Player do ustawień domyślnych';

  @override
  String get resetPreferences => 'Zresetuj preferencje';

  @override
  String get resetTo0Db => 'Zresetuj do 0 dB';

  @override
  String get resolution => 'Rozdzielczość';

  @override
  String get resonance => 'Rezonans';

  @override
  String get restart => 'Uruchom ponownie';

  @override
  String get restartRequired => 'Wymagane ponowne uruchomienie';

  @override
  String get restartTheAppToApplyPlayback =>
      'Uruchom ponownie aplikację, aby zastosować zmiany w odtwarzaniu.';

  @override
  String get restartYourDeviceToApplyOutput =>
      'Uruchom ponownie urządzenie, aby zastosować zmiany w formacie wyjściowym.';

  @override
  String get restartingFlick => 'Ponowne uruchamianie Hadoo';

  @override
  String results(Object arg1) {
    return 'Wyniki ($arg1)';
  }

  @override
  String get resumeAFamiliarFavoriteOrShuffle =>
      'Wznów znajomy ulubiony utwór lub przetasuj jeden z miksów utworzonych na podstawie tego, czego słuchasz.';

  @override
  String get resumeOnReconnect => 'Wznów po ponownym połączeniu';

  @override
  String get retakePhoto => 'Powtórz zdjęcie';

  @override
  String get retroFuture => 'Retro przyszłość';

  @override
  String get retry => 'Ponów próbę';

  @override
  String get reviewBeforeYouClean => 'Przejrzyj, zanim zaczniesz sprzątać';

  @override
  String get rightBottom => 'Prawo (na dole)';

  @override
  String get rightBottomButton => 'Prawy (dolny) przycisk';

  @override
  String get rightTop => 'Prawo (na górze)';

  @override
  String get rightTopButton => 'Prawy (górny) przycisk';

  @override
  String get ripSource => 'Źródło zgrywania';

  @override
  String get root => 'Korzeń';

  @override
  String get rotationSeek => 'wyszukiwanie rotacyjne';

  @override
  String get roundedAlbumArtCardWithA =>
      'Zaokrąglona karta z okładką albumu z rozmytym tłem okładki albumu.';

  @override
  String get route => 'Trasa';

  @override
  String get routesBluetoothThroughTheHiRes =>
      'Przekazuje Bluetooth przez silnik Rust o wysokiej rozdzielczości';

  @override
  String get routesBluetoothThroughTheRustEngine =>
      'Kieruje Bluetooth przez silnik Rust';

  @override
  String get rustViaOboe => 'Rdza przez obój';

  @override
  String get rustViaOboeHighRes => 'Rdza przez obój (wysoka rozdzielczość)';

  @override
  String s(Object arg1) {
    return '$arg1';
  }

  @override
  String sAgo(Object arg1) {
    return '$arg1 temu';
  }

  @override
  String get sambaWindowsShareTransportPending => 'Samba · Udział Windows';

  @override
  String get sampleArtist => 'Przykładowy artysta';

  @override
  String get samplePreview => 'Przykładowy podgląd';

  @override
  String get sampleRate => 'Częstotliwość próbkowania';

  @override
  String get sampleRate2 => 'Częstotliwość próbkowania';

  @override
  String get sampleRates => 'Przykładowe stawki';

  @override
  String get sampleSongPreviewOnly => 'Przykładowy utwór · tylko podgląd';

  @override
  String get samples => 'Próbki';

  @override
  String get save => 'Zapisz';

  @override
  String get saveAsText => 'Zapisz jako tekst';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get saveConnect => 'Zapisz i połącz';

  @override
  String get saveCreatesAnLrcFileIf =>
      'Zapisz tworzy plik `.lrc`. Jeśli niektóre linie nie zostały jeszcze ostemplowane, Hadoo automatycznie wypełnia ich czasy, dzięki czemu plik pozostaje użyteczny. Eksport wierszy z całkowicie ostemplowanymi słowami z synchronizacją karaoke dla każdego słowa.';

  @override
  String get saveCurrentAsPreset => 'Zapisz bieżący jako ustawienie wstępne';

  @override
  String get saveCustomizeReplay => 'Zapisz / dostosuj powtórkę';

  @override
  String get saveInFlick => 'Zapisz w Hadoo';

  @override
  String get saveLogs => 'Zapisz logi';

  @override
  String get saveLrcFile => 'Zapisz plik LRC';

  @override
  String get saveLrcFile2 => 'Zapisz plik LRC';

  @override
  String get saveLyrics => 'Zapisz teksty';

  @override
  String get savePng => 'Zapisz PNG';

  @override
  String get savePreset => 'Zapisz ustawienie wstępne';

  @override
  String get saveTheCurrentEqAsJson => 'Zapisz bieżący EQ jako JSON lub TXT';

  @override
  String get saved => 'Zapisano';

  @override
  String get savedAgain => 'Zapisano · ponownie';

  @override
  String get savedAndVerified => 'Zapisane i zweryfikowane';

  @override
  String savedCollections(Object playlistCount) {
    return '$playlistCount zapisane kolekcje';
  }

  @override
  String get savedLyricsAndLinkedThemTo =>
      'Zapisano teksty i powiązano je z tą piosenką.';

  @override
  String get savedLyricsBesideTheSongAs =>
      'Tekst zapisany obok utworu jako plik `.lrc`.';

  @override
  String get savedLyricsToTheChosenLocation =>
      'Zapisano teksty w wybranej lokalizacji.';

  @override
  String get savedPlaylistsAndQuickJumpsInto =>
      'Zapisane listy odtwarzania i szybkie przejścia do organizacji biblioteki.';

  @override
  String get savedToGallery => 'Zapisano w galerii';

  @override
  String savedToNNNshareIt(Object path) {
    return 'Zapisano w:\n$path\n\nUdostępnij teraz?';
  }

  @override
  String savedToYourGallery(Object arg1) {
    return '$arg1 zapisano w Twojej galerii';
  }

  @override
  String get savedVerificationPending => 'Zapisano (oczekuje na weryfikację)';

  @override
  String get saving => 'Zapisywanie…';

  @override
  String get scaleTheAlbumArtCard => 'Skaluj kartę okładki albumu';

  @override
  String get scaleTheFullViewAlbumArt =>
      'Skaluj kartę okładki albumu w pełnym widoku';

  @override
  String get scalesWithWidgetSizeAutomatically =>
      'Automatycznie skaluje się wraz z rozmiarem widżetu';

  @override
  String get scanAgain => 'Zeskanuj ponownie';

  @override
  String get scanForDevices => 'Wyszukaj urządzenia';

  @override
  String get scanProgress => 'Postęp skanowania';

  @override
  String get scanningForDuplicates => 'Skanowanie w poszukiwaniu duplikatów…';

  @override
  String get scanningYourLibrary => 'Skanuję Twoją bibliotekę…';

  @override
  String get scroll => 'Przewiń';

  @override
  String get scrollForMore => 'Przewiń, aby zobaczyć więcej';

  @override
  String get scrollingPausesWhenReducedMotionIs =>
      'Przewijanie zostaje wstrzymane, gdy włączona jest funkcja ograniczonego ruchu';

  @override
  String get search => 'Szukaj';

  @override
  String get searchAcrossSongsArtistsAndAlbums =>
      'Błyskawicznie przeszukuj utwory, wykonawców i albumy.';

  @override
  String get searchAgain => 'Wyszukaj ponownie';

  @override
  String get searchArtistTitle => 'Wyszukaj wykonawcę + tytuł...';

  @override
  String get searchArtists => 'Szukaj artystów…';

  @override
  String get searchFailed => 'Wyszukiwanie nie powiodło się';

  @override
  String searchFailed2(Object e) {
    return 'Wyszukiwanie nie powiodło się: $e';
  }

  @override
  String get searchHeadphones => 'Wyszukaj słuchawki…';

  @override
  String searchModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Modele $count',
      one: 'Model $count',
    );
    return 'Szukaj $_temp0…';
  }

  @override
  String get searchOnline => 'Szukaj w Internecie';

  @override
  String get searchOnline2 => 'Szukaj w internecie';

  @override
  String get searchOnlineCreateYourOwnSynced =>
      'Szukaj online, twórz własne zsynchronizowane teksty lub importuj istniejący plik.';

  @override
  String get searchOnlineLyrics => 'Wyszukaj teksty piosenek w Internecie';

  @override
  String get searchSongsArtists => 'Wyszukaj utwory, wykonawców...';

  @override
  String get searchSongsArtistsAlbums =>
      'Wyszukaj utwory, wykonawców, albumy...';

  @override
  String get searchTheManual => 'Przeszukaj instrukcję...';

  @override
  String get searchYourLibrary => 'Szukaj w bibliotece';

  @override
  String get searching => 'Wyszukiwanie…';

  @override
  String get searchingOnline => 'Wyszukiwanie w Internecie';

  @override
  String get searchingTheLocalNetwork => 'Przeszukiwanie sieci lokalnej…';

  @override
  String get seeAll => 'Zobacz wszystko';

  @override
  String seeAll2(Object count) {
    return 'Zobacz wszystkie $count';
  }

  @override
  String get select => 'Wybierz';

  @override
  String get selectALineAndEdit =>
      '1. Wybierz linię i bezpośrednio edytuj jej znacznik czasu lub użyj opcji „Użyj bieżącego czasu”.\n2. Na osi czasu słowa przeciągnij granicę, aby rozciągnąć lub zmniejszyć segment znajdujący się przed nią — zmiany zostaną przyciągnięte do 10 ms.\n3. Stukaj w litery w inspektorze, aby podzielić słowo na osobne sylaby w odstępie czasowym (w tempie wolnym, a potem szybkim), a następnie przeciągnij ich granice.\n4. Przeciągnij ostatnią granicę (lub użyj opcji Długość ±), aby zmienić długość następnej linii. Użyj funkcji automatycznego wypełniania, aby umieścić słowa w równych odstępach.\n5. Użyj elementów sterujących shift, aby przenieść wszystkie ostemplowane teksty razem.\n6. Zapisz, aby wygenerować ostateczny plik `.lrc`.';

  @override
  String get selectARelease => 'Wybierz wersję';

  @override
  String get selectAll => 'Wybierz wszystko';

  @override
  String get selectAll2 => 'Zaznacz wszystko';

  @override
  String get selectDevice => 'Wybierz Urządzenie';

  @override
  String selected(Object count) {
    return 'Wybrano: $count';
  }

  @override
  String selectedOfSong(Object selected, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return 'Wybrano $selected $_temp0';
  }

  @override
  String get sep => 'wrzesień';

  @override
  String get separateFromNavBar => 'Oddzielone od paska nawigacyjnego';

  @override
  String get separateTheMiniPlayerToCustomize =>
      'Oddziel miniodtwarzacz, aby dostosować jego szerokość i odstęp. Twoje wartości niestandardowe zostaną zapisane podczas łączenia.';

  @override
  String get serialNumber => 'Numer seryjny';

  @override
  String serverPlaylistSyncFailed(Object e) {
    return 'Synchronizacja listy odtwarzania serwera nie powiodła się: $e';
  }

  @override
  String get serverUrl => 'Adres URL serwera';

  @override
  String get session => 'Sesja';

  @override
  String get setAlbumArt => 'Ustaw okładkę albumu';

  @override
  String get setToNow => 'Ustaw na Teraz';

  @override
  String get settings => 'Ustawienia';

  @override
  String get shadow => 'Cień';

  @override
  String get shadowJazz => 'Cień Jazzu';

  @override
  String get share => 'Udostępnij';

  @override
  String shareFailed(Object e) {
    return 'Udostępnianie nie powiodło się: $e';
  }

  @override
  String get sharedSecret => 'Wspólny sekret';

  @override
  String get shiftMetadataTextUpOrDown =>
      'Przesuń tekst metadanych w górę lub w dół';

  @override
  String get shiftOnlyTheAlbumArtUp =>
      'Przesuwaj w górę lub w dół tylko okładkę albumu';

  @override
  String get shiftOnlyTheSongDetailsUp =>
      'Przesuwaj w górę lub w dół tylko szczegóły utworu';

  @override
  String get showAThinPlaybackProgressLine =>
      'Pokaż cienką linię postępu odtwarzania';

  @override
  String get showAlbum => 'Pokaż album';

  @override
  String get showAlbum2 => 'Pokaż album';

  @override
  String get showAlbumArtwork => 'Pokaż okładkę albumu.';

  @override
  String get showAlbumArtworkOnTheMini =>
      'Pokaż okładkę albumu w miniodtwarzaczu';

  @override
  String get showArtist => 'Pokaż artystę';

  @override
  String get showArtist2 => 'Pokaż artystę';

  @override
  String get showArtistBelowSongTitle => 'Pokaż wykonawcę pod tytułem utworu';

  @override
  String get showFileInfo => 'Pokaż informacje o pliku';

  @override
  String get showFileInfo2 => 'Pokaż informacje o pliku';

  @override
  String get showFrame => 'Pokaż ramkę';

  @override
  String get showFrame2 => 'Pokaż ramkę';

  @override
  String get showLess => 'Pokaż mniej';

  @override
  String get showLyrics => 'Pokaż tekst';

  @override
  String get showMore => 'Pokaż więcej';

  @override
  String get showOtherArtistsOnAlbumPages =>
      'Pokaż innych artystów na stronach albumów';

  @override
  String get showPassword => 'Pokaż hasło';

  @override
  String get showRelatedAlbumsOnAlbumPages =>
      'Pokaż powiązane albumy na stronach albumów';

  @override
  String get showTheArtistBelowTheSong => 'Pokaż wykonawcę pod tytułem utworu';

  @override
  String get showTheAudioVisualizerOffSaves =>
      'Pokaż wizualizator audio (wyłączenie oszczędza baterię)';

  @override
  String get showTheGlassFrameAroundAlbum =>
      'Pokaż szklaną ramkę wokół okładki albumu';

  @override
  String get showTheMiniPlayerAsIts =>
      'Pokaż miniodtwarzacz jako własny pasek nad przyciskami';

  @override
  String get showTheNumberOverBlurredArt =>
      'Pokaż numer na niewyraźnej grafice.';

  @override
  String get showTheTrackNumber => 'Pokaż numer utworu.';

  @override
  String get showTitle => 'Pokaż tytuł';

  @override
  String get showTitle2 => 'Pokaż tytuł';

  @override
  String get showVerboseAudioDiagnosticsAndEngine =>
      'Wyświetl pełną diagnostykę audio i dzienniki śledzenia silnika/sesji.';

  @override
  String get showVisualizer => 'Pokaż wizualizator';

  @override
  String showingAllAlbums(Object totalCount) {
    return 'Wyświetlanie wszystkich albumów $totalCount';
  }

  @override
  String showingOfAlbums(Object visibleCount, Object totalCount) {
    return 'Wyświetlanie albumów $visibleCount z $totalCount';
  }

  @override
  String get showingYourLastLoadedReplay =>
      'Wyświetlanie ostatniej załadowanej powtórki.';

  @override
  String get shownWhenThereIsRoomBeside =>
      'Wyświetlany, gdy obok elementów sterujących jest miejsce';

  @override
  String get showsWhatSPlayingTapTo =>
      'Pokazuje, co jest odtwarzane. Kliknij, aby otworzyć pełny odtwarzacz.';

  @override
  String get shuffle => 'Losowo';

  @override
  String shuffle2(Object arg1) {
    return 'Losuj: $arg1';
  }

  @override
  String get shuffleFavorites => 'Mieszaj ulubione';

  @override
  String get shuffleMode => 'Tryb losowy';

  @override
  String get shuffleSongsAndJumpBetweenCategories =>
      'Mieszaj utwory i przeskakuj między kategoriami';

  @override
  String get shuffleSongsInCurrentList => 'Mieszaj utwory na bieżącej liście';

  @override
  String get signInFailedRetry =>
      'Logowanie nie powiodło się — spróbuj ponownie';

  @override
  String get signInWithTidal => 'Zaloguj się za pomocą Tidal';

  @override
  String get signInWithYourAccountHifi =>
      'Zaloguj się na swoje konto · HiFi bezstratne';

  @override
  String get signInWithYourOwnTidal =>
      'Zaloguj się na swoje własne konto Tidal. Bezstratne odtwarzanie HiFi (FLAC/ALAC) odbywa się dzięki doskonałemu silnikowi; HiRes/MQA i Atmos są bramkowane przez Tidal i zamiast grać, pokażą błąd.';

  @override
  String get signal => 'Sygnał';

  @override
  String get signalAccurateUnverified => 'AccurateRip nie został zweryfikowany';

  @override
  String get signalAccurateVerified => 'AccurateRip zweryfikowany w dzienniku';

  @override
  String get signalAltSetting => 'Ustawienie alternatywne';

  @override
  String get signalBufferCapacity => 'Pojemność bufora';

  @override
  String get signalBufferFill => 'Wypełnienie bufora';

  @override
  String get signalBufferOccupancy => 'Zajętość bufora w godzinach otwarcia';

  @override
  String get signalBufferTarget => 'Cel bufora';

  @override
  String get signalCopyCrc => 'Skopiuj CRC';

  @override
  String get signalCrcCannotCompare => 'Nie można porównać';

  @override
  String get signalCrcComparison => 'Porównanie CRC';

  @override
  String get signalCrcMatch => 'Dopasuj';

  @override
  String get signalCrcMismatch => 'Niedopasowanie';

  @override
  String get signalDriftFromTarget => 'Dryf od celu';

  @override
  String get signalDsdBitRate => 'Szybkość transmisji DSD';

  @override
  String get signalFileFormat => 'Format pliku';

  @override
  String get signalFramesPerPacket => 'Ramki / pakiet';

  @override
  String get signalMaxPacket => 'Maksymalny pakiet';

  @override
  String get signalNoRipDescription =>
      'Nie znaleziono żadnych informacji o zgrywaniu ani weryfikacji tego utworu.';

  @override
  String get signalNotReported => 'Brak danych';

  @override
  String get signalNotVerified => 'Niezweryfikowano';

  @override
  String get signalRecordingUnavailable =>
      'Historia zgrywania jest niedostępna';

  @override
  String get signalRipDescription =>
      'Informacje z dziennika zgrywania, a nie etap bieżącej ścieżki odtwarzania.';

  @override
  String get signalRipProvenance => 'Ripowe pochodzenie';

  @override
  String get signalRipper => 'Rozpruwacz';

  @override
  String get signalServiceInterval => 'Interwał serwisowy';

  @override
  String get signalSnapshot => 'Podsumowanie';

  @override
  String get signalSnapshotAtOpen => 'Zdjęcie przy otwartym';

  @override
  String get signalSourceDescription =>
      'Właściwości pliku źródłowego, a nie danych wyjściowych wysyłanych do urządzenia.';

  @override
  String get signalSourceDetails => 'Szczegóły formatu źródłowego';

  @override
  String get signalSubslot => 'Podszczelina';

  @override
  String get signalSyncType => 'Typ synchronizacji';

  @override
  String get signalTarget => 'cel';

  @override
  String get signalTestCrc => 'Przetestuj CRC';

  @override
  String get signalTransportFormat => 'Transportu';

  @override
  String get signalUnderruns => 'Podbiegi';

  @override
  String get signalUsageType => 'Typ użycia';

  @override
  String get signalUsbDescription =>
      'Wartości transportowe dostępne po otwarciu tego arkusza. To nie jest śledzenie pakietów na żywo.';

  @override
  String get signalUsbMissingDescription =>
      'Szczegóły URB są raportowane tylko dla bezpośredniej ścieżki USB. Nie wywnioskowano żadnej aktywności związanej z transferem.';

  @override
  String get signalUsbTransport => 'Transport USB';

  @override
  String get signalUsbUnavailable => 'Szczegóły transportu USB są niedostępne';

  @override
  String get signalVerificationMissing => 'Weryfikacja nie została zgłoszona';

  @override
  String get signalVerifiedInLog => 'Zweryfikowano w logu';

  @override
  String get signedIn => 'Zalogowano';

  @override
  String get silkySmoothBZierCurvesFluid =>
      'Jedwabiście gładkie krzywizny Béziera – płynne i organiczne';

  @override
  String get similarArtists => 'Podobni artyści';

  @override
  String get simple => 'Prosty';

  @override
  String get simpleMode => 'Tryb prosty';

  @override
  String get single => 'Singiel';

  @override
  String get size => 'Rozmiar';

  @override
  String get skip => 'Pomiń';

  @override
  String skippedUnmatchedEntr(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niedopasowane wpisy',
      one: '$count niedopasowany wpis',
    );
    return ' Pominięte $_temp0.';
  }

  @override
  String get sleepTimer => 'Timer uśpienia';

  @override
  String get sleepTimer2 => 'Wyłącznik czasowy';

  @override
  String get sleeves => 'Rękawy';

  @override
  String get slope => 'Nachylenie';

  @override
  String get smbSharesCanBeAddedNow =>
      'Udziały SMB2/3 łączą się poprzez wbudowanego klienta. Wprowadź adres URL udziału (smb://host/share) i zaloguj się, jeśli serwer o to poprosi.';

  @override
  String get smooth => 'Gładka';

  @override
  String get smoothsPeaksAndRaisesBodyBefore =>
      'Wygładza szczyty i podnosi korpus, zanim limiter przechwyci transjenty.';

  @override
  String get snappy => 'Zgryźliwy';

  @override
  String get softwareAppControlled =>
      'Oprogramowanie (kontrolowane przez aplikację)';

  @override
  String get solid => 'Solidne';

  @override
  String get someOnlineFeaturesMayNotWork =>
      '  · Niektóre funkcje online mogą nie działać';

  @override
  String get someWordsAreStillUntimedFinish =>
      'Niektóre słowa są jeszcze nieokreślone. Zakończ przechwytywanie w trybie Word Sync.';

  @override
  String get somethingWentWrong => 'Coś poszło nie tak';

  @override
  String song2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return '$_temp0';
  }

  @override
  String song3(int count, Object server) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return '$_temp0 · $server';
  }

  @override
  String get songActions => 'Działania utworu';

  @override
  String get songArtist => 'Artysta Piosenki';

  @override
  String get songCount => 'Liczba utworów';

  @override
  String get songGestures => 'Gesty pieśni';

  @override
  String get songMetadata => 'Metadane utworu';

  @override
  String get songTitle => 'Tytuł utworu';

  @override
  String songUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piosenki',
      one: 'piosenka',
    );
    return '$_temp0';
  }

  @override
  String songs(Object arg1, Object arg2) {
    return '$arg1 • Utwory $arg2';
  }

  @override
  String songs12(Object arg1) {
    return 'Piosenki $arg1';
  }

  @override
  String songs13(Object count) {
    return '$count utworów';
  }

  @override
  String get songs14 => 'Utwory';

  @override
  String songs15(Object arg1) {
    return 'Piosenki $arg1';
  }

  @override
  String songs2(Object songCount) {
    return 'Piosenki $songCount';
  }

  @override
  String songs3(Object arg1) {
    return 'Piosenki $arg1';
  }

  @override
  String songs4(Object _totalSongs) {
    return 'Piosenki $_totalSongs';
  }

  @override
  String songs5(Object arg1) {
    return 'Piosenki $arg1';
  }

  @override
  String songs9(Object arg1) {
    return 'Piosenki $arg1';
  }

  @override
  String songsAlbums(Object arg1, Object uniqueAlbums) {
    return 'Utwory $arg1 • Albumy $uniqueAlbums';
  }

  @override
  String songsAlbums2(Object arg1, Object albumCount) {
    return 'Utwory $arg1 · Albumy $albumCount';
  }

  @override
  String get songsCategories => 'Piosenki i kategorie';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piosenki $count',
      one: 'Piosenka $count',
    );
    return '$_temp0';
  }

  @override
  String songsFound(Object arg1) {
    return 'Znaleziono utwory $arg1';
  }

  @override
  String songsIn(int songs, int folders) {
    String _temp0 = intl.Intl.pluralLogic(
      songs,
      locale: localeName,
      other: 'Piosenki $songs',
      one: 'Piosenka $songs',
    );
    String _temp1 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: 'Foldery $folders',
      one: 'Folder $folders',
    );
    return '$_temp0 w $_temp1';
  }

  @override
  String songsInRotation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utwory $count w Twojej rotacji',
      one: 'Piosenka $count w Twojej rotacji',
    );
    return '$_temp0';
  }

  @override
  String get songsTab => 'Zakładka Piosenki';

  @override
  String songsU2022Albums(Object arg1, Object uniqueAlbums) {
    return 'Utwory $arg1 • Albumy $uniqueAlbums';
  }

  @override
  String get songsYouPlayWillAppearHere =>
      'Tutaj pojawią się odtwarzane przez Ciebie utwory';

  @override
  String get songsYouScanIntoYourLibrary =>
      'Tutaj pojawią się utwory, które zeskanujesz do swojej biblioteki';

  @override
  String get sortBy => 'SORTOWANIE WG';

  @override
  String get sortFilter => 'Sortuj i filtruj';

  @override
  String get sortSongs => 'Sortuj utwory';

  @override
  String get source => 'Źródło';

  @override
  String get sourceRate => 'Stawka źródłowa';

  @override
  String get spaceBetweenTheTwoBars => 'Odstęp między dwoma słupkami';

  @override
  String get spaceOdyssey => 'Odyseja Kosmiczna';

  @override
  String get spatialTime => 'Przestrzenny i czasowy';

  @override
  String get speedUp => 'Przyspiesz';

  @override
  String get springPhysicsEnergeticAndReactive =>
      'Fizyka wiosny — energetyczna i reaktywna';

  @override
  String get stampNext => 'Pieczęć i następny';

  @override
  String get stampNow => 'Pieczęć teraz';

  @override
  String get stampThisLineFirstToEdit =>
      'Najpierw stempluj tę linię, aby edytować jej oś czasu.';

  @override
  String get standard => 'Standard';

  @override
  String get standardBluetoothRoutingViaAndroid =>
      'Standardowy routing Bluetooth przez Androida';

  @override
  String get standardEngine => 'Silnik standardowy';

  @override
  String get starlightSerenade => 'Serenada Gwiazd';

  @override
  String get start => 'Zacznij';

  @override
  String get startAtNow => 'Zacznij od teraz';

  @override
  String get startBuildingYourHome => 'Zacznij budować swój dom';

  @override
  String get startPlayingToPopulateThisSpace =>
      'Zacznij grać, aby zapełnić to miejsce';

  @override
  String get startStreaming => 'Rozpocznij transmisję strumieniową';

  @override
  String get startedPresetDownload =>
      'Rozpoczęto pobieranie gotowych ustawień.';

  @override
  String get state => 'Stan';

  @override
  String get status => 'Status';

  @override
  String get stereo => 'Stereofoniczne';

  @override
  String get stop => 'Zatrzymaj';

  @override
  String get stopCasting => 'Zatrzymaj przesyłanie';

  @override
  String get stopStreaming => 'Zatrzymaj transmisję strumieniową';

  @override
  String get stopUsbOnQuit => 'Zatrzymaj USB po zakończeniu';

  @override
  String stoppingIn(Object arg1) {
    return 'Zatrzymanie w $arg1';
  }

  @override
  String get storeOn => 'Przechowuj dalej';

  @override
  String get storedAsASaltedHashNever =>
      'Przechowywane jako solony skrót, nigdy w postaci zwykłego tekstu';

  @override
  String get storedEncodedPlaybackUnavailableInThis =>
      'Przechowywane w formacie Base64 — wymagane do logowania NTLM';

  @override
  String get stormChasers => 'Łowcy burz';

  @override
  String get strategy => 'Strategia';

  @override
  String get stream => 'Strumień';

  @override
  String get streamConfigurationNotAvailable =>
      'Konfiguracja strumienia nie jest dostępna';

  @override
  String get streamStable => 'Strumień stabilny';

  @override
  String get streaming => 'Transmisja strumieniowa';

  @override
  String get streamingFromQueue => 'Transmisja strumieniowa z kolejki';

  @override
  String get strong => 'Silny';

  @override
  String get studioGradeOutputForExternalDacs =>
      'Wyjście klasy studyjnej dla zewnętrznych przetworników DAC i wzmacniaczy słuchawkowych. Omija przetwarzanie dźwięku Androida, zapewniając czysty dźwięk.';

  @override
  String get sub => 'Sub';

  @override
  String subfolderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Podfoldery $count',
      one: 'Podfolder $count',
    );
    return '$_temp0';
  }

  @override
  String get subsonic => 'Poddźwiękowy';

  @override
  String get subtle => 'Subtelny';

  @override
  String get supportFlick => 'Wsparcie Flick';

  @override
  String get supportFlickOnKoFi => 'Wsparcie Flick na Ko-fi';

  @override
  String get surfaceShading => 'Zacienienie powierzchni';

  @override
  String get swipeHorizontallyToFineTuneEach =>
      'Przesuń w poziomie, aby dostroić każde środkowe pasmo.';

  @override
  String get swipeLeftRightToSkipTracks =>
      'Przesuń w lewo/w prawo, aby pominąć utwory';

  @override
  String get swipeToShowOrHideThe =>
      'Przesuń, aby pokazać lub ukryć wizualizator';

  @override
  String get switchSongs => 'Zmień utwory';

  @override
  String get switchToTheExclusiveUsbPath =>
      'Automatycznie przełącz się na ekskluzywną ścieżkę USB po podłączeniu przetwornika cyfrowo-analogowego. Odrzucone przetworniki DAC są pamiętane.';

  @override
  String get switchedBackToTheAutomaticLyrics =>
      'Przełączono z powrotem na automatyczne źródło tekstów.';

  @override
  String get syllablesTapALetterToSplit =>
      'Sylaby — dotknij litery, aby ją podzielić lub połączyć:';

  @override
  String get symmetricalBarsMirroredFromTheCenter =>
      'Symetryczne słupki odbite lustrzanie od środka';

  @override
  String syncFailed(Object e) {
    return 'Synchronizacja nie powiodła się: $e';
  }

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get syncServerPlaylists => 'Synchronizuj listy odtwarzania serwera';

  @override
  String get synced => 'Zsynchronizowano';

  @override
  String synced2(Object arg1) {
    return 'Zsynchronizowano $arg1';
  }

  @override
  String get syncedLrc => 'Zsynchronizowany LRC';

  @override
  String syncedPlaylistFromServers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listy odtwarzania $count',
      one: 'Playlista $count',
    );
    return 'Zsynchronizowane $_temp0 z serwerów';
  }

  @override
  String get syncing => 'Synchronizowanie…';

  @override
  String get synthwaveCity => 'Miasto Synthwave’u';

  @override
  String get systemAndroidMixer => 'System (mikser Android)';

  @override
  String get tagsWereWrittenButCouldNot =>
      'Tagi zostały zapisane, ale nie można ich potwierdzić poprzez ponowne odczytanie pliku. Ponowne skanowanie biblioteki usunie wszelkie różnice.';

  @override
  String tap(Object label) {
    return 'Kliknij: „$label”';
  }

  @override
  String get tapABandToExpandDrag =>
      'Kliknij zespół, aby go rozwinąć. Przeciągnij pokrętło, aby dostosować. Kliknij wartość, aby wpisać ją bezpośrednio.';

  @override
  String get tapAllOrEnableAChip =>
      'Kliknij Wszystko lub włącz chip, aby zobaczyć wyniki';

  @override
  String get tapChipsToFilterCategories =>
      'Dotknij żetonów, aby filtrować kategorie';

  @override
  String get tapEditTextTopRight =>
      '1. Kliknij „Edytuj tekst” (w prawym górnym rogu) i wklej tekst — po jednej linijce w rzędzie.\n2. Odtwórz piosenkę.\n3. Wybierz bieżącą linię z listy Linie.\n4. Gdy usłyszysz tę linię, kliknij „Stempel i następny”.\n5. Zapisz, gdy skończysz.';

  @override
  String get tapIconsToSwitchTabsLong =>
      'Stukaj ikony, aby przełączać karty. Naciśnij długo, aby dostosować pasek.';

  @override
  String get tapTheHeartIconOnAny =>
      'Stuknij ikonę serca dowolnego utworu\n, aby dodać go do ulubionych';

  @override
  String get tapTheMiniPlayerForWaveform =>
      'Stuknij miniodtwarzacz, aby wyświetlić pasek wyszukiwania przebiegów, korektor dźwięku, teksty i wizualizator.';

  @override
  String get tapToInspect12602280Png =>
      'Kliknij, aby sprawdzić · 1260 × 2280 PNG';

  @override
  String get tapToPlayLongPressFor =>
      'Stuknij, aby odtworzyć, naciśnij długo, aby wyświetlić opcje (kolejka, graj dalej, informacje).';

  @override
  String get tapToPreview => 'Kliknij, aby wyświetlić podgląd';

  @override
  String targetMs(Object arg1) {
    return 'cel $arg1 ms';
  }

  @override
  String get tempo => 'Tempo';

  @override
  String tempoX(Object arg1) {
    return 'Tempo ${arg1}x';
  }

  @override
  String test(Object arg1) {
    return 'Test: $arg1';
  }

  @override
  String get testConnection => 'Połączenie testowe';

  @override
  String get textGestures => 'Tekst i gesty';

  @override
  String get textPlacement => 'Umieszczenie tekstu';

  @override
  String get textPlacement2 => 'Umieszczenie tekstu';

  @override
  String get textSize => 'Rozmiar tekstu';

  @override
  String get textSize2 => 'Rozmiar tekstu';

  @override
  String get thatSTheTour => 'To jest wycieczka!';

  @override
  String get theAudioEngineDeterminesHowYour =>
      'Silnik audio określa sposób odtwarzania muzyki. Każda opcja w inny sposób równoważy niezawodność, jakość i kompatybilność.';

  @override
  String get theIsochronousUsbEngineWillBe =>
      'Silnik Izochronous USB zostanie zatrzymany po zamknięciu aplikacji.';

  @override
  String get theIsochronousUsbEngineWillStay =>
      'Izochroniczny silnik USB pozostanie aktywny po zamknięciu aplikacji.';

  @override
  String get theNamesShowingUpAgainAnd =>
      'Nazwy pojawiające się wielokrotnie w Twojej ostatniej kolejce.';

  @override
  String get thePosterIsNotReadyYet =>
      'Plakat nie jest jeszcze gotowy. Spróbuj zapisać ponownie.';

  @override
  String get theTracksDominatingYourWeeklyAnd =>
      'Utwory dominujące w Twoim cotygodniowym i miesięcznym podsumowaniu.';

  @override
  String get thisAppIsBuiltByA =>
      'Ta aplikacja została zbudowana przez indywidualnego programistę z zerowym budżetem. Jeśli kochasz dźwięk wysokiej jakości, rozważ wsparcie jego rozwoju na platformie Ko-fi.';

  @override
  String get thisDevice => 'To urządzenie';

  @override
  String get thisFolderAppearsToBeEmpty => 'Ten folder wygląda na pusty';

  @override
  String get thisMonth => 'W tym miesiącu';

  @override
  String get thisMonthSRecap => 'Podsumowanie tego miesiąca';

  @override
  String thisRemovesAllEntriesFromMemory(Object arg1) {
    return 'Spowoduje to usunięcie wszystkich wpisów $arg1 z pamięci.';
  }

  @override
  String get thisSlowsPlaybackTo432440 =>
      'Spowalnia to odtwarzanie do 432/440 (~1,8% niższa wysokość i tempo) i wyłącza funkcję bit-perfect passthrough. Muzyka będzie brzmiała nieco niżej. Włącz tę opcję tylko wtedy, gdy celowo chcesz dostroić A=432.';

  @override
  String get thisSongHasNoFilePath =>
      'Ten utwór nie ma ścieżki pliku i nie można go edytować.';

  @override
  String get thisSongIsMissingAlbumMetadata =>
      'W tym utworze brakuje metadanych albumu, więc dopasowanie online jest ograniczone.';

  @override
  String get thisSongOnly => 'Tylko ta piosenka';

  @override
  String get thisWeek => 'W tym tygodniu';

  @override
  String get thisWeekSRecap => 'Podsumowanie tego tygodnia';

  @override
  String get thisYearSRecap => 'Podsumowanie tego roku';

  @override
  String get threshold => 'Próg';

  @override
  String get thunderRoad => 'Droga Grzmotu';

  @override
  String get tidal => 'Tidal';

  @override
  String get timeShift => 'Przesunięcie czasu';

  @override
  String get timestamp => 'Znacznik czasu';

  @override
  String get tips => 'Wskazówki';

  @override
  String get title => 'Tytuł';

  @override
  String get toRemove => 'Aby usunąć';

  @override
  String get today => 'Dzisiaj';

  @override
  String get todaySRecap => 'Dzisiejsze podsumowanie';

  @override
  String get toneControls => 'Kontrola tonów';

  @override
  String get tools => 'Narzędzia';

  @override
  String get top => 'Góra';

  @override
  String get topAlbum => 'Najlepszy album';

  @override
  String get topArtist => 'Najlepszy artysta';

  @override
  String get topArtists => 'Najpopularniejsi wykonawcy';

  @override
  String get topSongs => 'Najlepsze utwory';

  @override
  String get topSongs2 => 'Najpopularniejsze utwory';

  @override
  String get track => 'Utwór';

  @override
  String track2(Object arg1) {
    return 'Śledź $arg1';
  }

  @override
  String get track3 => 'Numer utworu';

  @override
  String get trackBitDepth => 'Głębia bitowa śledzenia';

  @override
  String get trackChannels => 'Śledź kanały';

  @override
  String get trackCount => 'Liczba utworów';

  @override
  String get trackDsdRate => 'Śledź współczynnik DSD';

  @override
  String get trackNumber => 'Numer utworu';

  @override
  String get trackSampleRate => 'Śledź częstotliwość próbkowania';

  @override
  String get trackTime => 'Śledź czas';

  @override
  String get trackTimeSumsTheFullDuration =>
      'Czas utworu sumuje pełny czas trwania zarejestrowanych odtworzeń.';

  @override
  String tracks(Object _totalTracks) {
    return 'Gąsienice $_totalTracks';
  }

  @override
  String tracks2(Object arg1) {
    return 'Gąsienice $arg1';
  }

  @override
  String tracks3(Object arg1) {
    return 'Gąsienice $arg1';
  }

  @override
  String tracks4(Object arg1) {
    return 'Gąsienice $arg1';
  }

  @override
  String tracks5(Object arg1, Object arg2) {
    return '$arg1 · $arg2 tory';
  }

  @override
  String tracks6(Object arg1) {
    return 'Gąsienice $arg1';
  }

  @override
  String tracks7(Object trackCount, Object arg1) {
    return 'Gąsienice $trackCount • $arg1';
  }

  @override
  String tracks8(Object arg1) {
    return 'Gąsienice $arg1';
  }

  @override
  String tracksLikedSongsPlaylists(
    Object songCount,
    Object favoriteCount,
    Object playlistCount,
  ) {
    return 'Utwory $songCount, ulubione utwory $favoriteCount, listy odtwarzania $playlistCount';
  }

  @override
  String tracksReadyToRevisit(Object favoritesCount) {
    return 'Utwory $favoritesCount gotowe do ponownego odwiedzenia';
  }

  @override
  String get tracksThatFitTheQuieterSide =>
      'Utwory, które pasują do cichszej strony Twoich nawyków słuchania.';

  @override
  String get transparent => 'Przezroczysty';

  @override
  String get treble => 'Wysokie';

  @override
  String get trueRandomMayRepeatBeforeList =>
      'Prawdziwie losowe (może się powtórzyć przed końcem listy)';

  @override
  String get truncate => 'Obetnij';

  @override
  String get tryAdjustingYourSearchQuery => 'Spróbuj dostosować zapytanie';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get tryAnotherKeywordOrEnableMore =>
      'Wypróbuj inne słowo kluczowe lub włącz więcej kategorii';

  @override
  String get tryOriginalSearch => 'Spróbuj oryginalnego wyszukiwania';

  @override
  String get tryPickingALocalImageIf =>
      'Spróbuj wybrać obraz lokalny, jeśli metadane wersji są rzadkie.';

  @override
  String get typeABrandAndModelTo =>
      'Wpisz markę i model, aby wyszukać online.';

  @override
  String get u162ByteSubslotsLlRr => 'U16 — podsloty 2-bajtowe, LL|RR';

  @override
  String u2022(Object arg1, Object valueLabel) {
    return '$arg1  •  $valueLabel';
  }

  @override
  String u20223(Object arg1, Object gainLabel) {
    return '$arg1  •  $gainLabel';
  }

  @override
  String u2022Bit(Object arg1) {
    return ' • Bit $arg1';
  }

  @override
  String get u324ByteSubslotsLlllRrrr =>
      'U32 — 4-bajtowe podsloty, LLLL|RRRR (starsze)';

  @override
  String get u8ByteInterleavedLrlr => 'U8 — LRLR przeplatany bajtami';

  @override
  String get u8ByteInterleavedRecommendedDefault =>
      'U8 — przeplatane bajtami, zalecane ustawienie domyślne';

  @override
  String get uac2IsNotAvailableOnThis =>
      'UAC2 nie jest dostępny na tej platformie';

  @override
  String get uac2NotAvailableOnThisPlatform =>
      'UAC2 nie jest dostępne na tej platformie';

  @override
  String get uac2Preferences => 'Preferencje UAC2';

  @override
  String get uac2PreferencesResetSuccessfully =>
      'Ustawienia preferencji UAC2 zostały pomyślnie zresetowane';

  @override
  String get unableToCheckForUpdatesRight =>
      'Nie można teraz sprawdzić dostępności aktualizacji.';

  @override
  String unavailable(Object featureName) {
    return '$featureName Niedostępne';
  }

  @override
  String get unavailable2 => 'Niedostępne';

  @override
  String underruns(Object arg1) {
    return 'Najazdy $arg1';
  }

  @override
  String get undo => 'Cofnij';

  @override
  String get unfavorite => 'Nieulubiony';

  @override
  String get unfavoriteSelected => 'Wybrano opcję Usuń z ulubionych';

  @override
  String get uniqueArtists => 'Wyjątkowi artyści';

  @override
  String get universalCompatibility => 'Uniwersalna kompatybilność';

  @override
  String get unknown => 'Nieznane';

  @override
  String get unknownAlbum => 'Nieznany album';

  @override
  String get unknownArtist => 'Nieznany wykonawca';

  @override
  String get unknownBitrate => 'Nieznana przepływność';

  @override
  String get unknownFolder => 'Nieznany folder';

  @override
  String get unknownTitle => 'Nieznany tytuł';

  @override
  String get unknownTrack => 'Nieznany utwór';

  @override
  String unlocked(Object unlocked, Object arg1) {
    return 'Odblokowano $unlocked / $arg1';
  }

  @override
  String get unmute => 'Wyłącz wyciszenie';

  @override
  String get unreported => 'Niezgłoszone';

  @override
  String get unsavedChanges => 'Niezapisane zmiany';

  @override
  String up(Object arg1) {
    return '$arg1 w górę';
  }

  @override
  String get upNext => 'Następny';

  @override
  String upcomingSong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nadchodzące utwory $count',
      one: 'Nadchodząca piosenka $count',
    );
    return '$_temp0';
  }

  @override
  String get update => 'Aktualizuj';

  @override
  String get updateAvailable => 'Dostępna aktualizacja';

  @override
  String get updateNoticeHidden => 'Powiadomienie o aktualizacji ukryte.';

  @override
  String updated(Object arg1) {
    return 'Zaktualizowano $arg1';
  }

  @override
  String updatedAlbumArtFor(Object arg1) {
    return 'Zaktualizowano okładkę albumu „$arg1”.';
  }

  @override
  String updatedAlbumArtFor2(Object arg1) {
    return 'Zaktualizowano okładkę albumu „$arg1”.';
  }

  @override
  String get upload => 'Prześlij';

  @override
  String uploadFailed(Object arg1) {
    return 'Przesyłanie nie powiodło się ($arg1).';
  }

  @override
  String uploadFailed2(Object e) {
    return 'Przesyłanie nie powiodło się: $e';
  }

  @override
  String get uploadLogsAsALink => 'Przesłać logi jako link?';

  @override
  String get upnpDlna => 'UPnP/DLNA';

  @override
  String get urbPacket => 'Pakiet URB';

  @override
  String get urbTransfer => 'Transfer URB';

  @override
  String get urbanEchoes => 'Miejskie echa';

  @override
  String get usbAudioDevice => 'Urządzenie audio USB';

  @override
  String get usbAudioDevices => 'Urządzenia audio USB';

  @override
  String get usbAudioError => 'Błąd dźwięku USB';

  @override
  String get usbDacAutoBitPerfectOffers =>
      'Funkcja automatycznego bit-perfect USB DAC oferuje reset.';

  @override
  String get usbNotConnected => 'USB nie jest podłączone';

  @override
  String get usbRouteVolume => 'Wolumen trasy USB';

  @override
  String get usbVolume => 'Głośność USB';

  @override
  String get useAFixed48khz16bitOutput =>
      'Aby uzyskać lepszą kompatybilność, użyj stałego wyjścia 48 kHz/16 bitów';

  @override
  String get useAaudioDirectlyLowestLatencyOn =>
      'Użyj AAudio bezpośrednio. Najniższe opóźnienie w systemie Android 8.1 i nowszych.';

  @override
  String get useAlbumArtAsBackground => 'Użyj okładki albumu jako tła';

  @override
  String get useAutoSource => 'Użyj automatycznego źródła';

  @override
  String get useCurrentTime => 'Użyj bieżącego czasu';

  @override
  String get useExistingFile => 'Użyj istniejącego pliku';

  @override
  String get useExistingFileInTheLyrics =>
      '- Opcja „Użyj istniejącego pliku” w panelu tekstów łączy plik `.lrc`, `.txt` lub `.xml`. \n – Jeśli niektóre linie nie są ostemplowane, Hadoo automatycznie wypełnia ich czasy. \n – Zapisz zapisuje obok utworu, jeśli to możliwe, w przeciwnym razie Hadoo przechowuje połączoną kopię.';

  @override
  String get useMmSsCcEG => 'Użyj mm:ss.cc, np. 01:23,45';

  @override
  String get useTheDefaultMonochromeTheme =>
      'Użyj domyślnego motywu monochromatycznego.';

  @override
  String get useTheHighestFixedOutputRate =>
      'Użyj najwyższej dostępnej stałej szybkości wyjściowej i głębi bitowej';

  @override
  String get useTheLegacyOpenslEsBackend =>
      'Użyj starszego backendu OpenSL ES. Rozwiązywanie problemów w przypadku starszych lub problematycznych urządzeń.';

  @override
  String get useTheVerifiedDirectUsbPath =>
      'Użyj zweryfikowanej bezpośredniej ścieżki USB i wyłącz programowe sterowanie DSP, które zakłócałoby odtwarzanie bit-perfekcyjne na zewnętrznym przetworniku cyfrowo-analogowym USB.';

  @override
  String get userToken => 'Token użytkownika';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get variableBitrateLowLatency =>
      'Zmienna przepływność, niskie opóźnienia';

  @override
  String get variousArtists2 => 'Różni artyści';

  @override
  String get velvetNoir => 'Aksamitny Czarny';

  @override
  String get vendorId => 'Identyfikator dostawcy';

  @override
  String get verboseDartRustAndCrashLogs =>
      'Szczegółowe dzienniki Dart, Rust i awarii';

  @override
  String get verified => 'Zweryfikowano';

  @override
  String version2(Object arg1) {
    return 'Wersja $arg1';
  }

  @override
  String get verticalBarsClassicSpectrumAnalyzer =>
      'Pionowe słupki — klasyczny analizator widma';

  @override
  String get verticalBarsThatAnimateAcrossThe =>
      'Pionowe paski animowane na ekranie.';

  @override
  String get vibrant => 'Żywy';

  @override
  String get viewAsGrid => 'Wyświetl jako siatkę';

  @override
  String get viewAsList => 'Wyświetl jako listę';

  @override
  String get viewMetadata => 'Wyświetl metadane';

  @override
  String get viewQueue => 'Zobacz kolejkę';

  @override
  String get visualizer => 'Wizualizator';

  @override
  String get visualizerAlbumColorsDescription =>
      'Postępuj zgodnie z kolorami okładek albumu; monochromatyczny, gdy jest niedostępny';

  @override
  String get visualizerBlocks => 'Zanikające bloki';

  @override
  String get visualizerBlocksDescription =>
      'Segmentowane słupki z delikatnie zanikającymi śladami';

  @override
  String get visualizerColors => 'Kolory';

  @override
  String get visualizerMonochrome => 'Monochromatyczny';

  @override
  String get visualizerMonochromeDescription =>
      'Biało-szary, niezależny od okładki albumu';

  @override
  String get visualizerRainbow => 'Tęcza';

  @override
  String get visualizerRainbowDescription =>
      'Spektrum kolorów w całym wizualizerze';

  @override
  String get volume => 'Głośność';

  @override
  String get volumeControl => 'Regulacja głośności';

  @override
  String get volumeIsFixedWhileBitPerfect =>
      'Głośność jest stała, gdy aktywne jest przejście bit-perfect, a ten przetwornik cyfrowo-analogowy nie ma sprzętowej regulacji głośności.';

  @override
  String get volumeIsFixedWhileBitPerfect2 =>
      'Głośność jest stała, gdy aktywne jest przejście bit-perfect: strumień jest przesyłany w stanie nienaruszonym, a ten przetwornik cyfrowo-analogowy nie ma sprzętowej regulacji głośności.';

  @override
  String wAgo(Object arg1) {
    return '${arg1}w temu';
  }

  @override
  String get waitingForBrowserAuthorization =>
      'Oczekiwanie na autoryzację przeglądarki...';

  @override
  String get waitingForPlayback => 'Oczekiwanie na odtworzenie';

  @override
  String get wantEveryControlDocumentedOpenThe =>
      'Chcesz udokumentować każdą kontrolę? Otwórz podręcznik w aplikacji w dowolnym momencie, wybierając Ustawienia → Pomoc i instrukcja.';

  @override
  String was(Object arg1) {
    return 'było: $arg1';
  }

  @override
  String get wave => 'Fala';

  @override
  String get waveform => 'Przebieg fali';

  @override
  String weLlKeepTheBestQuality(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kopie $count',
      one: 'Kopia $count',
    );
    return 'Zachowamy wersję o najlepszej jakości w każdej grupie (preferujemy okładkę albumu, a następnie najwyższą szybkość transmisji) i usuniemy $_temp0. Pliki na dysku nie są usuwane.';
  }

  @override
  String weLlKeepYourCheckedVersion(int kept, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      kept,
      locale: localeName,
      other: 'Sprawdzone wersje $kept',
      one: 'Sprawdzona wersja $kept',
    );
    String _temp1 = intl.Intl.pluralLogic(
      removed,
      locale: localeName,
      other: 'Kopie $removed',
      one: 'Kopia $removed',
    );
    return 'Zatrzymamy Twoje $_temp0 i usuń drugi $_temp1 ze swojej biblioteki. Pliki audio na dysku nie są usuwane.';
  }

  @override
  String get webdav => 'WebDAV';

  @override
  String get weekly => 'Co tydzień';

  @override
  String get welcomeBackLetSStartA =>
      'Witamy ponownie — zacznijmy dobrą passę.';

  @override
  String get welcomeToFlick => 'Witamy w Hadoo!';

  @override
  String get welcomeToFlick2 => 'Witamy w Hadoo';

  @override
  String get whatSNew => 'Co nowego';

  @override
  String get whenYouPlayOverBluetoothAndroid =>
      'Gdy grasz przez Bluetooth, Android negocjuje kodek ze słuchawkami lub głośnikiem.';

  @override
  String get whereShouldTheLrcFileBe =>
      'Gdzie powinien zostać zapisany plik .lrc?';

  @override
  String get whisperWorld => 'Świat Szeptów';

  @override
  String get whisperedSecrets => 'Szeptane tajemnice';

  @override
  String get white => 'Biały';

  @override
  String get wholeAlbum => 'Cały album';

  @override
  String wide(Object amount) {
    return '$amount% szerokości';
  }

  @override
  String get widgets => 'Widżety';

  @override
  String get width => 'Szerokość';

  @override
  String get wildWeather => 'Dzika pogoda';

  @override
  String get willBeRemoved => 'Zostaną usunięte';

  @override
  String get willKeep => 'Zachowa';

  @override
  String get wiredOutput => 'Wyjście przewodowe';

  @override
  String word(Object arg1, Object arg2) {
    return 'Słowo $arg1 · „$arg2”';
  }

  @override
  String word2(Object arg1, Object token) {
    return 'Słowo $arg1 · „$token”';
  }

  @override
  String get wordSync => 'Synchronizacja słów';

  @override
  String get wordSyncModeKaraoke => 'Tryb Word Sync (karaoke)';

  @override
  String wordTimelineLine(Object arg1) {
    return 'Oś czasu słowa · Linia $arg1';
  }

  @override
  String get writeADescription => 'Napisz opis';

  @override
  String x(Object min) {
    return '${min}x';
  }

  @override
  String x2(Object max) {
    return '${max}x';
  }

  @override
  String x3(Object currentSpeed) {
    return '${currentSpeed}x';
  }

  @override
  String yAgo(Object arg1) {
    return '$arg1 temu';
  }

  @override
  String get year => 'Rok';

  @override
  String get yearly => 'Rocznie';

  @override
  String get yesterday => 'Wczoraj';

  @override
  String get youCanAlsoChangeTheCodec =>
      'Możesz także zmienić kodek w Opcjach programisty Androida w sekcji „Kodek audio Bluetooth”.';

  @override
  String get youCustomizedWhichVersionsToKeep =>
      'Spersonalizowałeś wersje, które chcesz zachować. Świetnie – masz kontrolę.';

  @override
  String get youHaveUnsavedChangesAreYou =>
      'Masz niezapisane zmiany. Czy na pewno chcesz je odrzucić?';

  @override
  String get youHaveUnsavedLyricEditsLeave =>
      'Masz niezapisane zmiany tekstu. Opuścić Sync Studio bez zapisywania?';

  @override
  String get youReOffline => 'Jesteś offline';

  @override
  String get youReOfflineSomeOnlineFeatures =>
      'Jesteś offline. Niektóre funkcje online mogą nie działać.';

  @override
  String get youVeHitTheThresholdKeep => 'Osiągnąłeś próg – tak trzymaj!';

  @override
  String get yourCollectionAtAGlance => 'Twoja kolekcja w skrócie';

  @override
  String get yourCustomCollections => 'Twoje niestandardowe kolekcje';

  @override
  String get yourHeaviestRotationRightNow =>
      'Twoja najcięższa rotacja w tej chwili';

  @override
  String get yourLatestLibraryScans => 'Twoje najnowsze skany biblioteki';

  @override
  String get yourLibrary => 'Twoja biblioteka';

  @override
  String get yourLibraryAtAGlance => 'Twoja biblioteka w skrócie';

  @override
  String get yourLibraryIsTidyWeLl =>
      'Twoja biblioteka jest uporządkowana. Poinformujemy Cię, jeśli po następnym skanowaniu pojawią się nowe duplikaty.';

  @override
  String get yourListeningHistoryIsStillYours =>
      'Twoja historia słuchania jest nadal Twoja. Spróbuj załadować go ponownie.';

  @override
  String get yourListensWillRemainOnListenbrainz =>
      'Twoje utwory pozostaną w ListenBrainz, ale Hadoo przestanie je przesyłać.';

  @override
  String get yourLogsAreUploadedToDpaste =>
      'Twoje dzienniki są przesyłane do dpaste.com jako niepubliczny link, który wygasa po 30 dniach. Każda osoba, której udostępnisz link, będzie mogła je odczytać — dzienniki mogą zawierać ścieżki plików i szczegóły urządzenia.';

  @override
  String get yourMonthlyRecapNeedsABit =>
      'Twoje miesięczne podsumowanie wymaga w tym miesiącu nieco więcej czasu na słuchanie.';

  @override
  String get yourMostReplayedTrack => 'Twój najczęściej odtwarzany utwór';

  @override
  String get yourMusicIsBeingScrobbled => 'Twoja muzyka jest scrobblowana';

  @override
  String get yourMusicIsBeingSubmitted => 'Trwa przesyłanie Twojej muzyki';

  @override
  String get yourMusicOnRepeat => 'Twoja muzyka. Powtarzając.';

  @override
  String get yourNewAudioEngineIsReady =>
      'Twój nowy silnik audio jest gotowy. Uruchom ponownie Hadoo, aby go zastosować.';

  @override
  String get yourNextFavoriteIsWaiting => 'Twój następny ulubieniec już czeka.';

  @override
  String get yourNextFavoriteNisWaiting => 'Twój następny ulubiony\n czeka.';

  @override
  String get yourPlaylists => 'Twoje playlisty';

  @override
  String get yourScrobblingHistoryWillRemainOn =>
      'Twoja historia scrobblingu pozostanie w Last.fm, ale Hadoo przestanie wysyłać scrobble.';

  @override
  String get yourSessionHistory => 'Twoja historia sesji';

  @override
  String get yourWeeklyRecapAppearsOnceYou =>
      'Twoje cotygodniowe podsumowanie pojawi się, gdy zaczniesz słuchać w tym tygodniu.';

  @override
  String get yourWholeLibraryLivesHereTap =>
      'Mieszka tu cała twoja biblioteka. Stuknij dowolny utwór, aby go odtworzyć.';

  @override
  String get yourYearlyRecapFillsInAs =>
      'Twoje roczne podsumowanie będzie się wypełniać w miarę słuchania przez cały rok.';

  @override
  String get linkDesktop => 'Link do pulpitu';

  @override
  String get linkDevices => 'Urządzenia';

  @override
  String get linkConnectDesktop => 'Podłącz swój pulpit Hadoo';

  @override
  String get linkPairingHint =>
      'Na pulpicie otwórz aplikację Phone Remote i wybierz opcję Sparuj telefon. Trzymaj oba urządzenia w tej samej sieci Wi-Fi.';

  @override
  String get linkScanQr => 'Zeskanuj kod QR parowania';

  @override
  String get linkInvalidQr => 'To nie jest prawidłowy kod parowania Hadoo.';

  @override
  String get linkCameraUnavailable =>
      'Dostęp do aparatu jest niedostępny. Wróć i zamiast tego wprowadź adres komputera i kod parowania.';

  @override
  String get linkSearchDesktops => 'Znajdź komputery stacjonarne w sieci Wi-Fi';

  @override
  String get linkSearching => 'Szukasz komputerów stacjonarnych…';

  @override
  String get linkNoDesktopFound =>
      'Nie znaleziono pulpitu. Możesz wpisać jego adres ręcznie.';

  @override
  String get linkDesktopAddress => 'Adres pulpitu';

  @override
  String get linkPairingCode => 'Sześciocyfrowy kod parowania';

  @override
  String get linkPair => 'Sparuj komputer stacjonarny';

  @override
  String get linkConnecting => 'Łączenie…';

  @override
  String get linkMatchTheme => 'Dopasuj motyw pulpitu i akcent';

  @override
  String get linkConnected => 'Połączono';

  @override
  String get linkOffline => 'Nieaktywny';

  @override
  String get linkReconnect => 'Połącz ponownie';

  @override
  String get linkDisconnect => 'Rozłącz';

  @override
  String get linkForget => 'Zapomnij o pulpicie';

  @override
  String get linkForgetDescription =>
      'Usunąć zapisane dane uwierzytelniające tego komputera z tego telefonu? Twoja muzyka i połączona biblioteka pozostaną na tym telefonie.';

  @override
  String get linkActionFailed =>
      'Łącze na pulpicie nie mogło zakończyć tej akcji.';

  @override
  String get linkPlayback => 'Wyjście odtwarzania';

  @override
  String get linkControlDesktop => 'Steruj pulpitem z poziomu Teraz odtwarzane';

  @override
  String get linkPlayOnDesktop => 'Graj na komputerze';

  @override
  String get linkPlayOnPhone => 'Graj na tym telefonie';

  @override
  String get linkUpdateDesktop =>
      'Zaktualizuj Hadoo na swoim komputerze, aby sterować z niego telefonem i synchronizować swoją bibliotekę.';

  @override
  String get linkMergeLibraries => 'Połącz swoje biblioteki';

  @override
  String get linkMergePreview =>
      'Zachowaj muzykę, polubienia i playlisty z obu urządzeń. Ukończone sztuki są łączone raz. Żadne pliki muzyczne nie zostaną usunięte. Późniejsze zmiany są synchronizowane w obu kierunkach.';

  @override
  String get linkMerge => 'Połącz';

  @override
  String get linkNotNow => 'Nie teraz';

  @override
  String linkHistoryCount(int count) {
    return 'Odtwarzanie pulpitu $count jest gotowe do połączenia';
  }

  @override
  String get linkSendDownloads =>
      'Wysyłaj pliki do pobrania z telefonu na komputer';

  @override
  String get linkSendDownloadsDescription =>
      'Kopiuj nowe pobrania i brakujące utwory podczas przekazywania odtwarzania na sparowany komputer. Oryginały pozostają na telefonie.';

  @override
  String get linkLegacyRemote =>
      'Połącz się ręcznie ze starszym komputerem stacjonarnym';

  @override
  String get linkDownloadToPhone => 'Pobierz na telefon';

  @override
  String get linkDownloaded => 'Zapisano na tym telefonie';

  @override
  String linkOutputName(String name) {
    return 'Hadoo na $name';
  }

  @override
  String get linkOnboardingDescription =>
      'Steruj dowolnym urządzeniem, przesuwaj kolejkę między nimi i przechowuj polubienia, playlisty i historię słuchania razem. Jest to opcjonalne i można je skonfigurować później.';

  @override
  String get linkFollowAccent => 'Śledź akcent aplikacji';

  @override
  String get linkPerformanceTitle => 'Czy animacje są płynniejsze?';

  @override
  String get linkPerformanceBody =>
      'Tryb wydajności zachowuje motyw i wykorzystuje solidne powierzchnie zamiast szkła.';

  @override
  String get linkEnablePerformance => 'Użyj trybu wydajności';
}

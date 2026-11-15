// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aLittleRecordOfWhatStayed =>
      'Eine kleine Aufzeichnung dessen, was in der Wiederholung blieb.';

  @override
  String get aNewerFlickBuildIsOn =>
      'Ein neuerer Hadoo-Build ist im Play Store erhältlich.';

  @override
  String get aPlaylistWithThisNameAlready =>
      'Eine Playlist mit diesem Namen existiert bereits';

  @override
  String get aSmoothContinuousWaveAcrossFrequencies =>
      'Eine gleichmäßige, kontinuierliche Welle über alle Frequenzen hinweg';

  @override
  String get aSongWithALongTitle =>
      'Ein Lied mit einem langen Titel zur Vorschau';

  @override
  String get aTighterMixOfFavoritesAnd =>
      'Eine engere Mischung aus Favoriten und Songs, zu denen Sie immer wieder zurückkehren.';

  @override
  String get aWeekAndCountingYourDedication =>
      'Eine Woche und das Zählen – Ihr Engagement zeigt sich.';

  @override
  String get aaudio => 'AAudio';

  @override
  String get aaudioAndroid81 => 'AAudio (Android 8.1+)';

  @override
  String get aaudioWithOpenslEsFallbackDefault =>
      'AAudio mit OpenSL ES-Fallback (Standard)';

  @override
  String get about => 'Über';

  @override
  String get aboutThisAlbum => 'Über dieses Album';

  @override
  String get absoluteVolumeSync => 'Absolute Lautstärkesynchronisierung';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get accuraterip => 'AccurateRip';

  @override
  String achieved(Object arg1) {
    return 'Erreicht $arg1';
  }

  @override
  String get achievementUnlocked => 'ERFOLG FREIGESCHALTET';

  @override
  String get activateFallback => 'Fallback aktivieren';

  @override
  String get active => 'Aktiv';

  @override
  String activeBands(Object activeCount) {
    return '$activeCount aktive Bänder';
  }

  @override
  String get activeDays => 'Aktive Tage';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addAMusicFolderInSettings =>
      'Fügen Sie in den Einstellungen einen Musikordner hinzu';

  @override
  String get addANextTrackButton =>
      'Fügen Sie eine Schaltfläche für den nächsten Titel hinzu';

  @override
  String get addAPreviousTrackButton =>
      'Fügen Sie eine Schaltfläche für den vorherigen Titel hinzu';

  @override
  String get addAtLeastOneLyricLine =>
      'Fügen Sie zuerst mindestens eine Textzeile hinzu.';

  @override
  String get addDescription => 'Beschreibung hinzufügen';

  @override
  String get addDescription2 => 'Beschreibung hinzufügen';

  @override
  String get addMusicFoldersInSettings =>
      'Fügen Sie Musikordner in den Einstellungen hinzu';

  @override
  String get addMusicWithAlbumTagsTo =>
      'Fügen Sie Musik mit Album-Tags hinzu, um sie hier anzuzeigen';

  @override
  String get addMusicWithArtistTagsTo =>
      'Fügen Sie Musik mit Künstler-Tags hinzu, um sie hier anzuzeigen';

  @override
  String get addServer => 'Server hinzufügen';

  @override
  String get addSongsFromThePlayerMenu =>
      'Fügen Sie Songs aus dem Player-Menü hinzu';

  @override
  String get addSongsFromThePlayerOr =>
      'Fügen Sie Songs über das Player- oder Song-Aktionsmenü hinzu.';

  @override
  String addSongsToPlaylist(Object arg1) {
    return 'Fügen Sie $arg1-Songs zur Wiedergabeliste hinzu';
  }

  @override
  String addSongsToPlaylist2(Object arg1) {
    return 'Fügen Sie $arg1-Songs zur Playlist hinzu';
  }

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get addToFavorites2 => 'Zu Favoriten hinzufügen';

  @override
  String get addToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get addToPlaylist2 => 'Zur Playlist hinzufügen';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get addToQueue2 => 'Zur Warteschlange hinzufügen';

  @override
  String addedSongsTo(Object arg1, Object arg2) {
    return '$arg1-Songs zu „$arg2“ hinzugefügt';
  }

  @override
  String addedSongsTo2(Object arg1, Object playlistName) {
    return '$arg1-Songs zu $playlistName hinzugefügt';
  }

  @override
  String addedSongsToFavorites(Object arg1) {
    return '$arg1-Songs zu den Favoriten hinzugefügt';
  }

  @override
  String addedSongsToFavorites3(Object arg1) {
    return '$arg1-Songs zu den Favoriten hinzugefügt';
  }

  @override
  String addedSongsToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs zur Warteschlange hinzugefügt',
      one: 'Zur Warteschlange hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String addedTo(Object arg1) {
    return 'Zu $arg1 hinzugefügt';
  }

  @override
  String addedTo2(Object arg1) {
    return 'Hinzugefügt zu „$arg1“';
  }

  @override
  String get addedToFavorites => 'Zu den Favoriten hinzugefügt';

  @override
  String addedToFavorites2(Object arg1) {
    return '„$arg1“ zu den Favoriten hinzugefügt';
  }

  @override
  String get addsPreDriveAndCatchesPeaks =>
      'Fügt Vorantrieb hinzu und fängt Spitzenwerte bis zur endgültigen Ausgangsobergrenze auf.';

  @override
  String get adjustMetadataTextSizeInArtwork =>
      'Passen Sie die Textgröße der Metadaten im Grafikkartenmodus an';

  @override
  String get adjustMetadataTextSizeInImmersive =>
      'Passen Sie die Textgröße der Metadaten im immersiven Modus an';

  @override
  String get adjustTheMiniPlayerSurface =>
      'Passen Sie die Oberfläche des Mini-Players an';

  @override
  String get advanceToARandomCategory =>
      'Wechseln Sie zu einer zufälligen Kategorie';

  @override
  String get advanceToTheNextCategoryAlphabetically =>
      'Gehen Sie alphabetisch zur nächsten Kategorie vor';

  @override
  String get advanceToTheNextMostRecently =>
      'Wechseln Sie zur nächsten, zuletzt hinzugefügten Kategorie';

  @override
  String get advanced => 'Erweitert';

  @override
  String get advancedMode => 'Erweiterter Modus';

  @override
  String get afterHours => 'Nach Geschäftsschluss';

  @override
  String get afterScanningMatchFilesWithMissing =>
      'Vergleichen Sie nach dem Scannen Dateien mit fehlenden Tags mit Apple Music. Es gelten automatisch nur sichere Übereinstimmungen.';

  @override
  String get air => 'Luft';

  @override
  String get alacAudio => 'ALAC Audio';

  @override
  String alacBit(Object arg1) {
    return 'ALAC $arg1-Bit';
  }

  @override
  String get album => 'Album';

  @override
  String get albumArt => 'Albumcover';

  @override
  String get albumArt2 => 'Albumcover';

  @override
  String get albumArtist => 'Album-Interpret';

  @override
  String get albumArtists => 'Albumkünstler';

  @override
  String get albumArtwork => 'Albumcover';

  @override
  String get albumColors => 'Albumfarben';

  @override
  String get albumCount => 'Albumanzahl';

  @override
  String get albumLimit => 'ALBUM-LIMIT';

  @override
  String get albumName => 'Albumname';

  @override
  String get albumOptions => 'Albumoptionen';

  @override
  String get albums => 'Alben';

  @override
  String albums2(Object arg1) {
    return '$arg1-Alben';
  }

  @override
  String albums3(Object _totalAlbums) {
    return '$_totalAlbums-Alben';
  }

  @override
  String get albumsShownPerPage => 'Pro Seite angezeigte Alben';

  @override
  String albumsSongs(Object arg1, Object arg2) {
    return '$arg1-Alben • $arg2-Songs';
  }

  @override
  String get all => 'Alle';

  @override
  String get allArtists => 'Alle Künstler';

  @override
  String get allClearNoDuplicates => 'Alles klar – keine Duplikate';

  @override
  String get allFormats => 'Alle Formate';

  @override
  String get allFrequenciesEqually => 'Alle Frequenzen gleich';

  @override
  String get allPass => 'Alle passieren';

  @override
  String get allResultsAreHiddenByActive =>
      'Alle Ergebnisse werden durch aktive Filter ausgeblendet.';

  @override
  String get allSongs => 'Alle Lieder';

  @override
  String get allWordsStamped => 'Alle Wörter gestempelt';

  @override
  String get allowed => 'Erlaubt';

  @override
  String get alphabetical => 'Alphabetisch';

  @override
  String get alsoRespectsYourSystemTextSize =>
      'Berücksichtigt auch die Textgröße Ihres Systems';

  @override
  String alt(Object arg1) {
    return 'Alt $arg1';
  }

  @override
  String get amber => 'Bernstein';

  @override
  String get andArtwork => ' und Kunstwerke';

  @override
  String andMoreInRotation(Object arg1) {
    return '$arg1 und mehr in Rotation';
  }

  @override
  String get android => 'Android';

  @override
  String get androidAudioApi => 'Android-Audio-API';

  @override
  String get androidBlockedWritingToThisFile =>
      'Android hat das Schreiben in diese Datei blockiert. Entfernen Sie den Ordner und fügen Sie ihn erneut in den Einstellungen hinzu, um Bearbeitungszugriff zu gewähren. Versuchen Sie es dann erneut.';

  @override
  String get androidDeveloperOptionsTheReliableWay =>
      'Android-Entwickleroptionen – die zuverlässige Möglichkeit, den Codec zu wechseln (In-App-Erzwingung nutzt eine versteckte System-API, die auf Standard-Android blockiert ist)';

  @override
  String get androidDockRoute => 'Android-Dock-Route';

  @override
  String get androidManagedRustPlaybackPathUsing =>
      'Von Android verwalteter Rust-Wiedergabepfad mit dem nativen Oboe-Backend.';

  @override
  String get androidUsbRoute => 'Android-USB-Route';

  @override
  String get animationStyle => 'Animationsstil';

  @override
  String get apiKey => 'API-Schlüssel';

  @override
  String get appTitle => 'Hadoo';

  @override
  String get appearance => 'Darstellung';

  @override
  String get appleMusicDataUnavailable => 'Apple Music-Daten nicht verfügbar';

  @override
  String get appleMusicDataUpdated => 'Apple Music-Daten aktualisiert';

  @override
  String get appleMusicLookupFailedCheckYour =>
      'Apple Music-Suche ist fehlgeschlagen. Überprüfen Sie Ihre Verbindung.';

  @override
  String appliedAutoeqFor(Object arg1) {
    return 'Angewandter AutoEQ für $arg1';
  }

  @override
  String get apply => 'Anwenden';

  @override
  String apply2(Object arg1) {
    return 'Wenden Sie $arg1 an';
  }

  @override
  String get applySelected => 'Ausgewählte anwenden';

  @override
  String applyTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return 'Bewerben Sie sich bei $_temp0';
  }

  @override
  String get applyingNewAudioEngine => 'Anwenden der neuen Audio-Engine…';

  @override
  String get apr => 'Apr';

  @override
  String get aptxAdaptive => 'aptX Adaptive';

  @override
  String get aptxHd => 'aptX HD';

  @override
  String get areYouSureYouWantTo =>
      'Sind Sie sicher, dass Sie diese Playlist löschen möchten?';

  @override
  String get areYouSureYouWantTo2 =>
      'Sind Sie sicher, dass Sie Ihren gesamten Hörverlauf löschen möchten? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get areYouSureYouWantTo3 =>
      'Sind Sie sicher, dass Sie alle UAC2-Einstellungen zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get artist => 'Interpret';

  @override
  String get artistIsNotAvailableForThis =>
      'Für dieses Lied ist kein Interpret verfügbar';

  @override
  String get artistName => 'Künstlername';

  @override
  String artistUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Künstler',
      one: 'Künstler',
    );
    return '$_temp0';
  }

  @override
  String get artists => 'Künstler';

  @override
  String artists2(Object arg1) {
    return '$arg1 Künstler';
  }

  @override
  String get artistsInRotation => 'Künstler in Rotation';

  @override
  String get artwork => 'Cover';

  @override
  String get artworkCard => 'Kunstwerk-Karte';

  @override
  String get artworkPlacement => 'Platzierung von Kunstwerken';

  @override
  String get artworkPlacement2 => 'Platzierung von Kunstwerken';

  @override
  String get artworkSize => 'Kunstwerkgröße';

  @override
  String get artworkSize2 => 'Kunstwerkgröße';

  @override
  String get asmrDreams => 'ASMR-Träume';

  @override
  String atKhzBit(Object arg1, Object arg2) {
    return ' bei ${arg1}kHz/${arg2}bit';
  }

  @override
  String get atLeastOneVersionMustStay =>
      'Mindestens eine Version muss bestehen bleiben.';

  @override
  String get attack => 'Angriff';

  @override
  String get audioFocus => 'Audio-Fokus';

  @override
  String get audioFormat => 'Audioformat';

  @override
  String get audioFormatIsDisabled => 'Das Audioformat ist deaktiviert';

  @override
  String get audioSignalPath => 'Audiosignalpfad';

  @override
  String get aug => 'Aug';

  @override
  String get auto => 'Automatisch';

  @override
  String get autoAdvance => 'Automatischer Vorlauf';

  @override
  String get autoBeMsbDefaultOnlyChange =>
      'Auto – BE-MSB-Standard; Nur ändern, wenn natives DSD zischt';

  @override
  String get autoBitPerfectForUsbDacs => 'Auto Bit-perfekt für USB-DACs';

  @override
  String get autoFill => 'Automatisch ausfüllen';

  @override
  String get autoFullView => 'Automatische Vollansicht';

  @override
  String get autoIdentifyUntaggedAlbums =>
      'Identifizieren Sie Alben ohne Tags automatisch';

  @override
  String get autoNativeDsdOnDapsDop =>
      'Auto – Natives DSD auf DAPs, DoP für USB-DACs, ansonsten PCM';

  @override
  String get autoReconnect => 'Automatische Wiederverbindung';

  @override
  String get autoShowFullViewAfterInactivity =>
      'Vollständige Ansicht nach Inaktivität automatisch anzeigen';

  @override
  String get autoU8ByteInterleavedRecommended =>
      'Auto – U8 byte-interleaved (empfohlen)';

  @override
  String get autoeqHeadphones => 'AutoEQ-Kopfhörer';

  @override
  String get autoeqHeadphones2 => 'AutoEQ-Kopfhörer';

  @override
  String get automatic => 'Automatisch';

  @override
  String get availableDevices => 'Verfügbare Geräte';

  @override
  String b(Object arg1) {
    return 'B$arg1';
  }

  @override
  String get back => 'Zurück';

  @override
  String get backOnline => 'Wieder online';

  @override
  String get backToLocker => 'Zurück zu Locker';

  @override
  String get backToReplay => 'Zurück zur Wiedergabe';

  @override
  String get backend => 'Backend';

  @override
  String get background => 'Hintergrund';

  @override
  String get backgroundOpacity => 'Hintergrundopazität';

  @override
  String get balance => 'Gleichgewicht';

  @override
  String balance2(Object arg1) {
    return 'Waage $arg1';
  }

  @override
  String get balanceTempoDampFilterDelaysSize =>
      'Balance, Tempo, Dämpfung, Filter, Verzögerungen, Größe, Mischung und zusätzliche Spread-Regler.';

  @override
  String get balancedQualityAndStability =>
      'Ausgewogene Qualität und Stabilität';

  @override
  String get band => 'Band';

  @override
  String get bandControls => 'Bandsteuerung';

  @override
  String get bandEditors => 'Band-Herausgeber';

  @override
  String get bandPass => 'Bandpass';

  @override
  String bandU2022(Object arg1, Object arg2) {
    return 'Band $arg1 • $arg2';
  }

  @override
  String bands(Object arg1) {
    return '$arg1/31 Bänder';
  }

  @override
  String bandsActive(Object activeCount, Object arg1) {
    return '$activeCount/$arg1-Bänder aktiv';
  }

  @override
  String bandsAdjusted(Object adjustedBands) {
    return '$adjustedBands-Bänder angepasst';
  }

  @override
  String bandsAdjusted2(Object adjustedCount, Object arg1) {
    return '$adjustedCount/$arg1-Bänder angepasst';
  }

  @override
  String bandsPreampDb(Object arg1, Object arg2, Object arg3) {
    return '$arg1-Bänder · Vorverstärker $arg2 dB · $arg3';
  }

  @override
  String get bars => 'Bars';

  @override
  String get bass => 'Bass';

  @override
  String get bassMidTreble => 'Bässe, Mitten und Höhen';

  @override
  String get bassTreble => 'Bass + Höhen';

  @override
  String battery(Object battery) {
    return '$battery% Batterie';
  }

  @override
  String get beLsbBigEndianSubslotLsb =>
      'BE-LSB – Big-Endian-Subslot, LSB zuerst';

  @override
  String get beMsbBigEndianSubslotMsb =>
      'BE-MSB – Big-Endian-Subslot, MSB zuerst (Standard)';

  @override
  String get beMsbPackingTheDefaultWire =>
      'BE-MSB-Packung – die Standard-Drahtkonvention';

  @override
  String get besideTheSong => 'Neben dem Lied';

  @override
  String get bigEndian32BitSubslotMsb =>
      'Big-Endian-32-Bit-Subslot, MSB-erste Bits';

  @override
  String get bigEndianSubslotLsbFirstBit =>
      'Big-Endian-Subslot, LSB-first (Bit-umgekehrte) Bits';

  @override
  String bit(Object depth) {
    return '${depth}bit';
  }

  @override
  String get bitDepth => 'Bittiefe';

  @override
  String get bitDepth2 => 'Bittiefe';

  @override
  String get bitDepths => 'Bittiefen';

  @override
  String get bitPerfect => 'BIT-PERFEKT';

  @override
  String get bitPerfect2 => 'Etwas perfekt';

  @override
  String get bitPerfectCapsule => 'Bit-Perfekte Kapsel';

  @override
  String get bitPerfectDapInternal => 'Bit-perfekt (DAP-intern)';

  @override
  String get bitPerfectDapInternalDisabledSoftware =>
      'Bit-Perfekt (DAP-intern) deaktiviert – Softwareeffekte aktiv.';

  @override
  String get bitPerfectDapInternalEnabledAll =>
      'Bit-Perfekt (DAP-intern) aktiviert – alle DSPs werden umgangen.';

  @override
  String get bitPerfectEnabledParametricEqIs =>
      'Bit-perfekt aktiviert – parametrischer EQ wird auf dem direkten USB-Pfad umgangen. Starten Sie die App neu, um die Wiedergabeänderungen zu übernehmen.';

  @override
  String get bitPerfectUsbDac => 'Bit-perfekt (USB DAC)';

  @override
  String get bitPerfectUsbDacCouldNot =>
      'Bit-Perfekt (USB DAC) konnte nicht aktiviert werden. Überprüfen Sie die USB-Diagnose auf die Fehlerursache.';

  @override
  String bitPerfectUsbDacCouldNot2(Object arg1) {
    return 'Bit-Perfekt (USB DAC) konnte für $arg1 nicht aktiviert werden. Überprüfen Sie die USB-Diagnose.';
  }

  @override
  String bitPerfectUsbDacEnabledFor(Object arg1) {
    return 'Bit-perfekt (USB DAC) aktiviert für $arg1.';
  }

  @override
  String get bitPerfectVerified => 'Bit-perfekt verifiziert';

  @override
  String get bitSubslotsLlRrPer => '16-Bit-Subslots: LL|RR pro Frame';

  @override
  String get bitSubslotsLlllRrrrPer =>
      '32-Bit-Subslots: LLLL|RRRR pro Frame (Legacy)';

  @override
  String get bitrateAdjustsToSignalQuality =>
      'Die Bitrate passt sich der Signalqualität an';

  @override
  String get blocked => 'Blockiert';

  @override
  String get blue => 'Blau';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get bluetoothCodecInfo => 'Informationen zum Bluetooth-Codec';

  @override
  String get bluetoothOutput => 'Bluetooth-Ausgang';

  @override
  String get boldSaturatedColorsFromAlbumArt =>
      'Kräftige, gesättigte Farben des Albumcovers.';

  @override
  String get border => 'Grenze';

  @override
  String get bothBitPerfectOptionsAreOff =>
      'Beide bit-perfekten Optionen sind bei diesem DAP deaktiviert, sodass die Standard-Engine nicht verfügbar ist. Sie können Rust weiterhin über Oboe oder Isochronous USB verwenden.';

  @override
  String get bottom => 'Unten';

  @override
  String get bouncy => 'Hüpfend';

  @override
  String get browseByArtworkOpenAnyAlbum =>
      'Durchsuchen Sie nach Kunstwerken, öffnen Sie ein beliebiges Album und springen Sie direkt zur Titelliste.';

  @override
  String get browseYourArtistLibrary =>
      'Durchsuchen Sie Ihre Künstlerbibliothek';

  @override
  String get browseYourArtistsExploreTheirDiscographies =>
      'Durchsuchen Sie Ihre Künstler, erkunden Sie ihre Diskografien und spielen Sie ihre Titel.';

  @override
  String get buffer => 'Puffer';

  @override
  String build(Object kAppVersion, Object kAppBuild) {
    return '$kAppVersion ($kAppBuild erstellen)';
  }

  @override
  String get buildingYourMusicHome => 'Bauen Sie Ihr Musikhaus';

  @override
  String get builtIn => 'Eingebaut';

  @override
  String by(Object arg1, Object arg2) {
    return '„$arg1“ von $arg2';
  }

  @override
  String get bypassAllDspEqDynamicsCrossfade =>
      'Umgehen Sie alle DSPs (EQ, Dynamik, Crossfade, Geschwindigkeit) auf dem nativen DAP-internen hochauflösenden Pfad. Deaktivieren Sie die Verwendung von Softwareeffekten. Durch Ausschalten von Bit-Perfect (USB DAC) wird dies ebenfalls deaktiviert.';

  @override
  String get byteInterleavedLrlrStream => 'Byte-interleaved: LRLR-Stream';

  @override
  String get calmFrequencies => 'Ruhige Frequenzen';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraAccessIsNeededYouCan =>
      'Kamerazugriff ist erforderlich. Sie können es in den Android-Einstellungen aktivieren.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String capMs(Object arg1) {
    return 'Kappe $arg1 ms';
  }

  @override
  String get capabilities => 'Fähigkeiten';

  @override
  String get capabilitiesNotAvailable => 'Funktionen nicht verfügbar';

  @override
  String get capabilityState => 'Fähigkeitsstatus';

  @override
  String get cast => 'Besetzung';

  @override
  String get casting => 'Übertragung';

  @override
  String get castingTapToManage => 'Casting – zum Verwalten tippen';

  @override
  String castingTo(Object deviceName) {
    return 'Casting nach $deviceName';
  }

  @override
  String castingTo2(Object arg1) {
    return 'Casting nach $arg1';
  }

  @override
  String get categories => 'Kategorien';

  @override
  String get ceiling => 'Decke';

  @override
  String get center => 'Mitte';

  @override
  String get centeredWidensToFitYourControls =>
      'Zentriert; lässt sich erweitern, um sich an Ihre Bedienelemente anzupassen';

  @override
  String ch(Object channels) {
    return '$channels Kap';
  }

  @override
  String ch2(Object ch) {
    return '$ch Kap';
  }

  @override
  String ch3(Object arg1, Object arg2) {
    return '$arg1 / ${arg2}ch';
  }

  @override
  String get changingSampleRateBitDepthOr =>
      'Durch das Ändern der Abtastrate, der Bittiefe oder der Kanalverwaltung können Songs neu abgetastet werden und auf einigen Geräten die Wiedergabequalität, Tonhöhe, Geschwindigkeit oder Stabilität beeinträchtigen.';

  @override
  String get channels => 'Kanäle';

  @override
  String channels2(Object arg1) {
    return '$arg1-Kanäle';
  }

  @override
  String channels3(Object ch) {
    return '$ch-Kanäle';
  }

  @override
  String get checkTheVersionsYouWantTo =>
      'Markieren Sie die Versionen, die Sie behalten möchten – nicht markierte Versionen werden aus Ihrer Bibliothek entfernt. Zumindest einer muss bleiben.';

  @override
  String get checkVersionsToKeepUncheckedWill =>
      'Überprüfen Sie die beizubehaltenden Versionen – nicht markierte Versionen werden entfernt';

  @override
  String get chooseAction => 'Wählen Sie Aktion';

  @override
  String get chooseAudioEngine => 'Wählen Sie Audio Engine';

  @override
  String get chooseLocationU2026 => 'Standort wählen…';

  @override
  String get chooseWhichToKeep => 'Wählen Sie aus, was Sie behalten möchten';

  @override
  String get chromecast => 'Chromecast';

  @override
  String get circularDotsRadiusFollowsAmplitude =>
      'Kreisförmige Punkte – der Radius folgt der Amplitude';

  @override
  String get cityBeats => 'City Beats';

  @override
  String get claimedByFlick => 'Beansprucht von Hadoo';

  @override
  String get cleanStraightLineWithPrecisionScrubbing =>
      'Saubere gerade Linien durch präzises Schrubben.';

  @override
  String get clear => 'Leeren';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get clearAllUac2Settings => 'Löschen Sie alle UAC2-Einstellungen';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get clearLogs => 'Protokolle löschen?';

  @override
  String get clearWord => 'Klares Wort';

  @override
  String get clearWords => 'Klare Worte';

  @override
  String get close => 'Schließen';

  @override
  String get closePreview => 'Vorschau schließen';

  @override
  String codecApplied(Object arg1) {
    return 'Angewendeter Codec: $arg1';
  }

  @override
  String get codecControl => 'Codec-Steuerung';

  @override
  String get codecForcingUnavailableOnThisDevice =>
      'Codec-Erzwingung ist auf diesem Gerät nicht verfügbar – stellen Sie es über Entwickleroptionen → Bluetooth-Audio-Codec ein.';

  @override
  String get codecInfo => 'Codec-Info';

  @override
  String get codecU0026Audio => 'Codec und Audio';

  @override
  String get collapsed => 'Zusammengebrochen';

  @override
  String get collection => 'Sammlung';

  @override
  String get color => 'Farbe';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get compatibility => 'Kompatibilität';

  @override
  String get compatibleWithPowerampEq => 'Kompatibel mit Poweramp EQ';

  @override
  String get compressor => 'Kompressor';

  @override
  String get compressorOff => 'Kompressor aus';

  @override
  String get compressorOn => 'Kompressor an';

  @override
  String get connect => 'Verbinden';

  @override
  String get connectAMusicServer => 'Schließen Sie einen Musikserver an';

  @override
  String get connectASubsonicJellyfinWebdavUpnp =>
      'Schließen Sie einen Subsonic-, Jellyfin-, WebDAV-, UPnP- oder Tidal-Server an, um Ihre Remote-Bibliothek zu streamen.';

  @override
  String get connectAUsbDacOrAudio =>
      'Schließen Sie einen USB-DAC oder ein Audio-Interface an';

  @override
  String get connectListenbrainz => 'Verbinden Sie ListenBrainz';

  @override
  String get connectToScrobbleYourListeningHistory =>
      'Stellen Sie eine Verbindung her, um Ihren Hörverlauf zu scannen';

  @override
  String get connectToScrobbleYourMusic =>
      'Stellen Sie eine Verbindung her, um Ihre Musik zu scrobbeln';

  @override
  String get connectToSubmitYourListeningHistory =>
      'Stellen Sie eine Verbindung her, um Ihren Hörverlauf zu übermitteln';

  @override
  String get connected => 'Verbunden';

  @override
  String get connectedAccount => 'Verbundenes Konto';

  @override
  String connectedAs(Object username) {
    return 'Verbunden als $username';
  }

  @override
  String get connecting => 'Verbinden';

  @override
  String get connection => 'Verbindung';

  @override
  String get connectionBehavior => 'Verbindungsverhalten';

  @override
  String get connectionFailedRetry =>
      'Verbindung fehlgeschlagen – erneut versuchen';

  @override
  String get connectionManagement => 'Verbindungsmanagement';

  @override
  String get connectionOk => 'Verbindung ok';

  @override
  String get connectionStatus => 'Verbindungsstatus';

  @override
  String containsValuesOutsideTheSupportedRanges(Object presetName) {
    return '„$presetName“ enthält Werte außerhalb der unterstützten Bereiche; diese wurden angepasst:';
  }

  @override
  String get content => 'Inhalt';

  @override
  String get contentControls => 'Inhalt und Kontrollen';

  @override
  String get contentPlacement => 'Inhaltsplatzierung';

  @override
  String get contentPlacement2 => 'Inhaltsplatzierung';

  @override
  String get continueLabel => 'Weiter';

  @override
  String conversionFailed(Object error) {
    return 'Konvertierung fehlgeschlagen: $error';
  }

  @override
  String convertedSuccessfully(Object fileName) {
    return '$fileName erfolgreich konvertiert';
  }

  @override
  String get convertingAudio => 'Audio konvertieren...';

  @override
  String convertingToWav(Object fileName) {
    return 'Konvertieren von $fileName in WAV...';
  }

  @override
  String get convolverImpulseResponse => 'Convolver / Impulsantwort';

  @override
  String copies(Object arg1, Object arg2) {
    return '$arg1 • $arg2 kopiert';
  }

  @override
  String get copy => 'Kopieren';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get copyYourUserTokenFromListenbrainz =>
      'Kopieren Sie Ihr Benutzertoken aus den ListenBrainz-Einstellungen und fügen Sie es unten ein.';

  @override
  String get copyright => 'Urheberrecht';

  @override
  String get cornerRadius => 'Eckenradius';

  @override
  String get cosmicOrchestra => 'Kosmisches Orchester';

  @override
  String get couldNotConnectToLastFm =>
      'Es konnte keine Verbindung zu Last.fm hergestellt werden. Überprüfen Sie Ihre API-Anmeldeinformationen und versuchen Sie es erneut.';

  @override
  String get couldNotConnectToListenbrainzCheck =>
      'Es konnte keine Verbindung zu ListenBrainz hergestellt werden. Überprüfen Sie Ihr Token und versuchen Sie es erneut.';

  @override
  String get couldNotLoadAlbumSongs =>
      'Die Songs des Albums konnten nicht geladen werden';

  @override
  String get couldNotCreateThePosterImage =>
      'Das Posterbild konnte nicht erstellt werden.';

  @override
  String get couldNotLoadArtistSongs =>
      'Künstlerlieder konnten nicht geladen werden';

  @override
  String couldNotLoadIr(Object e) {
    return 'IR: $e konnte nicht geladen werden';
  }

  @override
  String get couldNotLoadSession => 'Sitzung konnte nicht geladen werden';

  @override
  String get couldNotOpenBrowser => 'Der Browser konnte nicht geöffnet werden.';

  @override
  String get couldNotOpenKoFiPlease =>
      'Ko-fi konnte nicht geöffnet werden. Bitte versuchen Sie es erneut.';

  @override
  String couldNotOpenLink2(Object e) {
    return 'Link konnte nicht geöffnet werden: $e';
  }

  @override
  String get couldNotOpenThatPhotoTry =>
      'Das Foto konnte nicht geöffnet werden. Versuchen Sie es mit einem anderen Bild.';

  @override
  String get couldNotOpenThePlayStore =>
      'Der Play Store konnte nicht geöffnet werden.';

  @override
  String couldNotOpenThePlayStore2(Object error) {
    return 'Der Play Store konnte nicht geöffnet werden: $error';
  }

  @override
  String get couldNotReadTheCoverColors =>
      'Die Coverfarben konnten nicht gelesen werden. Das Signal ist weiterhin verfügbar.';

  @override
  String get couldNotReadTheSelectedLyrics =>
      'Die ausgewählte Liedtextdatei konnte nicht gelesen werden.';

  @override
  String get couldNotSaveTheLyricsFile =>
      'Die Liedtextdatei konnte nicht gespeichert werden.';

  @override
  String get couldNotSaveYourRecapPlease =>
      'Ihre Zusammenfassung konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.';

  @override
  String get couldNotUseTheSelectedLyrics =>
      'Die ausgewählte Liedtextdatei konnte nicht verwendet werden.';

  @override
  String get couldnTOpenTheBrowserAutomatically =>
      'Der Browser konnte nicht automatisch geöffnet werden. Autorisieren Sie auf jedem Gerät mit diesem Link – wir schließen die Anmeldung ab, sobald Sie dies getan haben:';

  @override
  String get countingFiles => 'Dateien zählen…';

  @override
  String get create => 'Erstellen';

  @override
  String get createACollection => 'Erstellen Sie eine Sammlung';

  @override
  String get createACustomPreset =>
      'Erstellen Sie eine benutzerdefinierte Voreinstellung';

  @override
  String get createAPlaylistImportAnM3u =>
      'Erstellen Sie eine Wiedergabeliste, importieren Sie ein M3U oder lassen Sie die oben genannten Mixe die Sitzung tragen.';

  @override
  String get createLyrics => 'Erstellen Sie Songtexte';

  @override
  String get createNewPlaylist => 'Neue Playlist erstellen';

  @override
  String get createNewPlaylist2 => 'Neue Playlist erstellen';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get createPlaylistFromSelected =>
      'Erstellen Sie eine Playlist aus ausgewählten';

  @override
  String get createYourFirstPlaylistOrJump =>
      'Erstellen Sie Ihre erste Playlist oder springen Sie in Ihre gespeicherten Sammlungen.';

  @override
  String get createYourFirstPlaylistToOrganize =>
      'Erstellen Sie Ihre erste Playlist zum Organisieren\ndeine Lieblingslieder';

  @override
  String created(Object arg1) {
    return 'Erstellt $arg1';
  }

  @override
  String createdAndAddedSong(Object arg1) {
    return '$arg1 erstellt und Lied hinzugefügt';
  }

  @override
  String createdAndAddedSongs(Object name, Object arg1) {
    return '$name erstellt und $arg1-Songs hinzugefügt';
  }

  @override
  String get creativeFx => 'Kreative Effekte';

  @override
  String credentialsRejectedByReEnterThe(Object arg1) {
    return 'Anmeldeinformationen wurden von $arg1 abgelehnt. Geben Sie das Passwort erneut ein.';
  }

  @override
  String get credentialsSavedSuccessfully =>
      'Anmeldedaten erfolgreich gespeichert!';

  @override
  String get crystalCaverns => 'Kristallhöhlen';

  @override
  String get cueSheetTracksCannotBeEdited =>
      'CUE-Sheet-Spuren können nicht bearbeitet werden.';

  @override
  String get cueSheetTracksCannotBeEdited2 =>
      'CUE-Sheet-Spuren können nicht bearbeitet werden';

  @override
  String get currentArtwork => 'Aktuelle Kunstwerke';

  @override
  String get currentCustomArt => 'Aktuelle benutzerdefinierte Kunst';

  @override
  String get currentPlaybackMode => 'Aktueller Wiedergabemodus';

  @override
  String currentRoute(Object arg1) {
    return 'Aktuelle Route: $arg1.';
  }

  @override
  String get currentSongPreviewOnly => 'Aktueller Song · Nur Vorschau';

  @override
  String get currentStreak => 'Aktueller Streak';

  @override
  String get curvePreview => 'Kurvenvorschau';

  @override
  String get curvedWave => 'Gebogene Welle';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get customFormat => 'Benutzerdefiniertes Format';

  @override
  String get customFormatForcesPlaybackToThe =>
      'Benutzerdefiniertes Format erzwingt die Wiedergabe im ausgewählten Ausgabeformat. Wenn die gewählte Abtastrate, Bittiefe oder Kanäle nicht zum Song oder Gerät passen, hören Sie möglicherweise veränderten Ton, Tonhöhe, Geschwindigkeit oder Instabilität.';

  @override
  String get customFormatIsDisabledInBit =>
      'Das benutzerdefinierte Format ist im Bit-Perfect-Modus (USB-DAC) deaktiviert, da eine exakte Abtastratenanpassung erforderlich ist. Deaktivieren Sie Bit-Perfect (USB DAC), um benutzerdefinierte Formate festzulegen.';

  @override
  String get customFormatIsUnavailableBecauseAudio =>
      'Das benutzerdefinierte Format ist nicht verfügbar, da das Audioformat in den Einstellungen deaktiviert ist.';

  @override
  String get customWidth => 'Benutzerdefinierte Breite';

  @override
  String get customizeAudioDisplayNavigationAnd =>
      'Passen Sie Audio, Anzeige, Navigation und Integrationen an.';

  @override
  String get customizeBottomBar => 'Passen Sie die untere Leiste an';

  @override
  String dAgo(Object arg1) {
    return 'Vor ${arg1}d';
  }

  @override
  String dAgo2(Object arg1) {
    return 'Vor ${arg1}d';
  }

  @override
  String get dacClaim => 'DAC-Anspruch';

  @override
  String dacWillBeOfferedAgain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DACs',
      one: '$count DAC',
    );
    return '$_temp0 wird wieder angeboten.';
  }

  @override
  String get daily => 'Täglich';

  @override
  String get damp => 'Feuchte';

  @override
  String get dapNativeBitOrder => 'DAP Native Bitreihenfolge';

  @override
  String get dapNativeByteGrouping => 'DAP Native Byte-Gruppierung';

  @override
  String get dark => 'Dunkel';

  @override
  String get date => 'Datum';

  @override
  String get dateAdded => 'Datum hinzugefügt';

  @override
  String get dateAddedNewest => 'Datum hinzugefügt (Neueste)';

  @override
  String get dateAddedOldest => 'Datum hinzugefügt (ältestes)';

  @override
  String get dayStreak => 'Tagessträhne';

  @override
  String get dayStreak2 => 'Tagessträhne';

  @override
  String get dayStreak3 => 'Tagessträhne';

  @override
  String dayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage',
      one: 'Tag',
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
    return '$arg1 dB-Absenkung';
  }

  @override
  String dbMax(Object arg1) {
    return '$arg1 dB max';
  }

  @override
  String get deactivateFallback => 'Fallback deaktivieren';

  @override
  String get dec => 'Dez';

  @override
  String get decode => 'Dekodieren';

  @override
  String get deepEarth => 'Tiefe Erde';

  @override
  String get defaultAndroidPlaybackEngineUsedBy =>
      'Standardmäßige Android-Wiedergabe-Engine, die derzeit von Hadoo verwendet wird.';

  @override
  String get defaultAndroidPlayerPlaysEverything =>
      'Standard-Android-Player – spielt alles zuverlässig ab. Für die meisten Zuhörer die sicherste Wahl.';

  @override
  String get delays => 'Verzögerungen';

  @override
  String get delete => 'Löschen';

  @override
  String deleteAndAllSongsAndPlaylists(Object arg1) {
    return '„$arg1“ und alle damit synchronisierten Songs und Playlists löschen? Zwischengespeicherte Downloads bleiben erhalten.';
  }

  @override
  String get deleteFile => 'Datei löschen';

  @override
  String get deleteFiles => 'Dateien löschen';

  @override
  String get deletePlaylist => 'Playlist löschen';

  @override
  String get deletePreset => 'Voreinstellung löschen?';

  @override
  String get deleteSelected => 'Ausgewählte löschen';

  @override
  String get deleteSong => 'Lied löschen';

  @override
  String get deleteSong2 => 'Lied löschen?';

  @override
  String get deleteSong3 => 'Lied löschen';

  @override
  String deleteSongs(Object arg1) {
    return '$arg1-Songs löschen?';
  }

  @override
  String get deleteSongs2 => 'Lieder löschen';

  @override
  String deleteThisCannotBeUndone(Object arg1) {
    return '„$arg1“ löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String deleted(Object arg1) {
    return '„$arg1“ gelöscht';
  }

  @override
  String deletedSongs(Object arg1) {
    return 'Gelöschte $arg1-Songs';
  }

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get designed => 'Entworfen';

  @override
  String get details => 'Details';

  @override
  String get developerMode => 'Entwicklermodus';

  @override
  String get developerOptionsIsDisabledEnableIt =>
      'Entwickleroptionen sind deaktiviert. Aktivieren Sie es über Einstellungen → Über das Telefon (tippen Sie siebenmal auf Build-Nummer) und versuchen Sie es dann erneut.';

  @override
  String get device => 'Gerät';

  @override
  String get deviceCapabilities => 'Gerätefunktionen';

  @override
  String get deviceConnected => 'Gerät angeschlossen';

  @override
  String get deviceDac => 'Geräte-DAC';

  @override
  String get deviceDacVolume => 'DAC-Lautstärke des Geräts';

  @override
  String get deviceDisconnected => 'Gerät getrennt';

  @override
  String get deviceInformation => 'Geräteinformationen';

  @override
  String get deviceType => 'Gerätetyp';

  @override
  String get devices => 'Geräte';

  @override
  String get direct => 'Direkt';

  @override
  String get directAlsaOutputIsActiveAnd =>
      'Die direkte ALSA-Ausgabe ist aktiv und umgeht den Android-Audioserver.';

  @override
  String get directLibusbIsochronousUsbEngineBest =>
      'Direkte libusb isochrone USB-Engine. Am besten gepaart mit Bit-perfect (USB DAC) für verifizierte externe DAC-Wiedergabe.';

  @override
  String get directUsb => 'Direktes USB';

  @override
  String get directUsbDeviceManaged => 'Direkte USB-Geräteverwaltung';

  @override
  String get directUsbExperimental => 'Direktes USB-Experiment';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get disabledInBitPerfectUsbDac =>
      'Deaktiviert im Bit-Perfect-Modus (USB-DAC) (genaue Rate erforderlich)';

  @override
  String get disabledWhileBothBitPerfectOptions =>
      'Deaktiviert, während beide Bit-Perfekt-Optionen auf diesem DAP deaktiviert sind.';

  @override
  String get disc => 'Scheibe';

  @override
  String get disc2 => 'Scheibe #';

  @override
  String get discard => 'Verwerfen';

  @override
  String get discardChanges => 'Änderungen verwerfen?';

  @override
  String get discardChanges2 => 'Änderungen verwerfen?';

  @override
  String get disconnect => 'Trennen';

  @override
  String disconnectFrom(Object arg1) {
    return 'Trennen Sie die Verbindung zu $arg1';
  }

  @override
  String get disconnectLastFm => 'Last.fm trennen?';

  @override
  String get disconnectListenbrainz => 'ListenBrainz trennen?';

  @override
  String get discoversDlnaUpnpAndChromecastReceivers =>
      'Erkennt DLNA-, UPnP- und Chromecast-Empfänger in Ihrem Netzwerk';

  @override
  String get dismiss => 'Entlassen';

  @override
  String get displayFileFormatAndBitrateIn =>
      'Dateiformat und Bitrate im immersiven Modus anzeigen';

  @override
  String get displayFileFormatAndBitrateIn2 =>
      'Dateiformat und Bitrate im Grafikkartenmodus anzeigen';

  @override
  String get displayTheAlbumNameInArtwork =>
      'Zeigen Sie den Albumnamen im Artwork-Kartenmodus an';

  @override
  String get displayTheArtistNameInArtwork =>
      'Zeigen Sie den Namen des Künstlers im Grafikkartenmodus an';

  @override
  String get displayTheArtistNameInImmersive =>
      'Zeigen Sie den Namen des Künstlers im immersiven Modus an';

  @override
  String get displayTheTrackTitleInArtwork =>
      'Zeigen Sie den Titeltitel im Artwork-Kartenmodus an';

  @override
  String get displayTheTrackTitleInImmersive =>
      'Zeigen Sie den Titeltitel im immersiven Modus an';

  @override
  String get dlnaAndUpnpReceiversAreControlled =>
      'DLNA- und UPnP-Empfänger werden direkt in pure Dart gesteuert – keine zusätzlichen Abhängigkeiten. Die Chromecast-Unterstützung verwendet das native Cast SDK. Netzwerkquellen (Subsonic, WebDAV, Jellyfin, UPnP), lokale Dateien und zwischengespeicherte Songs können alle übertragen werden – Einheimische werden direkt von diesem Telefon aus bedient. Während des Castings steuern die Lautstärketasten und das Systemlautstärkefeld das angeschlossene Gerät.';

  @override
  String get dlnaUpnp => 'DLNA / UPnP';

  @override
  String get donTShowAgainToday => 'Heute nicht mehr zeigen';

  @override
  String get done => 'Fertig';

  @override
  String get dop => 'DoP';

  @override
  String get dots => 'Punkte';

  @override
  String get doubleTapABandToReset =>
      'Tippen Sie zum Zurücksetzen zweimal auf ein Band';

  @override
  String get doubleTapToReset => 'Zum Zurücksetzen doppeltippen';

  @override
  String get doubleTapToResetThisBand =>
      'Doppeltippen, um dieses Band zurückzusetzen';

  @override
  String down(Object arg1) {
    return '$arg1 unten';
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
      'Ziehen Sie eine Grenze, um das Wort davor zu strecken oder zu verkleinern. Die letzte Grenze verschiebt die nächste Zeile.';

  @override
  String get dragBandsUpOrDown => 'Ziehen Sie die Bänder nach oben oder unten';

  @override
  String get dragToChangeFrequencyGain =>
      'Ziehen Sie, um Frequenz und Verstärkung zu ändern';

  @override
  String get dragToMovePinchToWiden =>
      'Zum Verschieben ziehen. • Zum Erweitern/Verengen zusammenziehen';

  @override
  String get dragVerticallyToChangeGain =>
      'Vertikal ziehen, um die Verstärkung zu ändern';

  @override
  String driftMs(Object arg1) {
    return 'Drift $arg1 ms';
  }

  @override
  String get dsdMode => 'DSD-Modus';

  @override
  String get dsdOutputMode => 'DSD-Ausgabemodus';

  @override
  String get dsdStream => 'DSD-Stream';

  @override
  String get duplicateCleaner => 'Duplikatreiniger';

  @override
  String get duplicatesRemovedUsingRecommendedPicks =>
      'Duplikate werden mit den empfohlenen Picks entfernt.';

  @override
  String get duration => 'Dauer';

  @override
  String get durationMatch => 'Dauer-Match';

  @override
  String get dynamics => 'Dynamik';

  @override
  String get earlier => 'Früher';

  @override
  String get earlierStandoutsPulledBackIntoView =>
      'Frühere Highlights wurden aus Ihrem Hörverlauf wieder ins Blickfeld gerückt.';

  @override
  String get editCredentials => 'Anmeldeinformationen bearbeiten';

  @override
  String get editDescription => 'Beschreibung bearbeiten';

  @override
  String get editDescription2 => 'Beschreibung bearbeiten';

  @override
  String get editMetadata => 'Metadaten bearbeiten';

  @override
  String get editServer => 'Server bearbeiten';

  @override
  String get editSync => 'Bearbeiten und synchronisieren';

  @override
  String get editText => 'Text bearbeiten';

  @override
  String get editToken => 'Token bearbeiten';

  @override
  String get empty => 'Leer';

  @override
  String get emptyLine => '(Leere Zeile)';

  @override
  String get enable => 'Aktivieren';

  @override
  String get enable432HzTuning => '432-Hz-Tuning aktivieren?';

  @override
  String get enableEqToEdit => 'Aktivieren Sie den EQ zum Bearbeiten';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get endpoint => 'Endpunkt';

  @override
  String get engine => 'Motor';

  @override
  String enterAValidNumber(Object label) {
    return 'Geben Sie eine gültige $label-Nummer ein';
  }

  @override
  String enterAValueFromTo(Object arg1, Object arg2) {
    return 'Geben Sie einen Wert von $arg1% bis $arg2% ein.';
  }

  @override
  String get enterAYear19999 => 'Geben Sie ein Jahr ein (1–9999)';

  @override
  String get enterYourApiKey => 'Geben Sie Ihren API-Schlüssel ein';

  @override
  String get enterYourSharedSecret => 'Geben Sie Ihr gemeinsames Geheimnis ein';

  @override
  String ep(Object arg1) {
    return 'EP $arg1';
  }

  @override
  String get equalizer => 'Equalizer';

  @override
  String error(Object error) {
    return 'Fehler: $error';
  }

  @override
  String error2(Object arg1) {
    return 'Fehler: $arg1';
  }

  @override
  String get error3 => 'Fehler';

  @override
  String errorLoadingCapabilities(Object error) {
    return 'Fehler beim Laden der Funktionen: $error';
  }

  @override
  String get errorLoadingPlaylists => 'Fehler beim Laden der Playlists';

  @override
  String errorLoadingPlaylists2(Object error) {
    return 'Fehler beim Laden der Playlists: $error';
  }

  @override
  String get errorLoadingPreference => 'Fehler beim Laden der Präferenz';

  @override
  String get errorLoadingSongs => 'Fehler beim Laden der Songs';

  @override
  String get etherealTones => 'Ätherische Töne';

  @override
  String get everyAlbumHasArtistAndAlbum =>
      'Jedes Album verfügt über Künstler- und Album-Tags.';

  @override
  String get exactMatch => 'Genaue Übereinstimmung';

  @override
  String get exclusiveDirectPcmIsActiveAnd =>
      'Exklusives direktes PCM ist aktiv und umgeht den Android-Mixer mit der nativen Rate des Tracks.';

  @override
  String get exclusiveUsbBitPerfectReEngaged =>
      'Exklusiver USB-Anschluss, bitgenau wieder aktiviert.';

  @override
  String get exclusiveUsbDroppedToTheAndroid =>
      'Exklusiver USB-Anschluss für den Android-Mixer. Bit-Perfect ist pausiert.';

  @override
  String get exclusiveUsbIsActiveAndBypassing =>
      'Exklusives USB ist aktiv und umgeht den Android-Mixer.';

  @override
  String get exclusiveUsbIsStillUnavailableCheck =>
      'Exklusives USB ist immer noch nicht verfügbar. Überprüfen Sie die USB-Diagnose.';

  @override
  String get expanded => 'Erweitert';

  @override
  String get experimental => 'Experimentell';

  @override
  String get experimentalDownTunePlaybackBy432 =>
      'Experimentell – stimmen Sie die Wiedergabe um 432/440 herunter. Dadurch wird der bitperfekte Passthrough deaktiviert und der DSP-Pfad ausgeführt.';

  @override
  String get exportAsM3u => 'Als .m3u exportieren';

  @override
  String get exportAsM3u8 => 'Als .m3u8 exportieren';

  @override
  String get exportCsv => 'CSV exportieren';

  @override
  String get exportCurrentPreset => 'Aktuelle Voreinstellung exportieren';

  @override
  String get exportEqualizerPreset => 'Equalizer-Voreinstellung exportieren';

  @override
  String exportFailed(Object e) {
    return 'Export fehlgeschlagen: $e';
  }

  @override
  String get exportFormat => 'Exportformat';

  @override
  String get exportTxt => 'TXT exportieren';

  @override
  String exportedPresetTo(Object savePath) {
    return 'Exportierte Voreinstellung nach $savePath';
  }

  @override
  String exportedPresetTo2(Object fallbackPath) {
    return 'Exportierte Voreinstellung nach $fallbackPath';
  }

  @override
  String exportedSongsTo(Object arg1, Object arg2) {
    return '$arg1-Songs nach „$arg2“ exportiert.';
  }

  @override
  String get externalLabel => 'Extern';

  @override
  String get externalSongsCannotBeEdited =>
      'Externe Songs können nicht bearbeitet werden.';

  @override
  String get externalSongsCannotBeEdited2 =>
      'Externe Songs können nicht bearbeitet werden';

  @override
  String get extraCovers => 'Zusätzliche Abdeckungen';

  @override
  String get failedToActivateFallback => 'Fehler beim Aktivieren des Fallbacks';

  @override
  String failedToAddToFavorites(Object arg1) {
    return '„$arg1“ konnte nicht zu den Favoriten hinzugefügt werden';
  }

  @override
  String get failedToDeactivateFallback =>
      'Fallback konnte nicht deaktiviert werden';

  @override
  String get failedToImportPresetFile =>
      'Der Import der Voreinstellungsdatei ist fehlgeschlagen.';

  @override
  String failedToSaveMetadata(Object e) {
    return 'Metadaten konnten nicht gespeichert werden: $e';
  }

  @override
  String get failedToSaveMetadata2 =>
      'Metadaten konnten nicht gespeichert werden.';

  @override
  String get failedToStartStreaming =>
      'Streaming konnte nicht gestartet werden';

  @override
  String get failedToStopStreaming => 'Streaming konnte nicht gestoppt werden';

  @override
  String get faintHueShiftFromAlbumArt =>
      'Leichte Farbtonverschiebung gegenüber dem Albumcover.';

  @override
  String get fallback => 'Rückfall';

  @override
  String get fallbackAudio => 'Fallback-Audio';

  @override
  String get fallbackAudioActivated => 'Fallback-Audio aktiviert';

  @override
  String get fallbackAudioDeactivated => 'Fallback-Audio deaktiviert';

  @override
  String get fallbackAudioWillBeUsedIf =>
      'Fallback-Audio wird verwendet, wenn das UAC2-Gerät ausfällt';

  @override
  String get fastDirectTrackingImmediateResponse =>
      'Schnelle Direktverfolgung – sofortige Reaktion';

  @override
  String get favoriteAll => 'Alle am liebsten';

  @override
  String get favoriteSongs => 'Lieblingslieder';

  @override
  String get favorites => 'Favoriten';

  @override
  String get favoritesYouHaveNotRevisitedLately =>
      'Favoriten, die Sie in letzter Zeit nicht erneut besucht haben';

  @override
  String get feb => 'Febr';

  @override
  String get feedback => 'Rückmeldung';

  @override
  String get file => 'Datei';

  @override
  String get fileInformation => 'Dateiinformationen';

  @override
  String get filePath => 'Dateipfad';

  @override
  String files2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Dateien',
      one: '$count-Datei',
    );
    return '$_temp0';
  }

  @override
  String get filter => 'Filtern';

  @override
  String get filterByFormat => 'NACH FORMAT FILTER';

  @override
  String get filterLogs => 'Protokolle filtern…';

  @override
  String get findAndCleanUpDuplicateSongs =>
      'Finden und bereinigen Sie doppelte Songs';

  @override
  String get findSongsArtistsAlbumsFolders =>
      'Finden Sie Songs, Künstler, Alben, Ordner ...';

  @override
  String finishingMetadataForSongs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fertigstellung der Metadaten für $count-Songs…',
      one: 'Fertigstellung der Metadaten für den $count-Song…',
    );
    return '$_temp0';
  }

  @override
  String get finishingUp => 'Zum Schluss…';

  @override
  String get fix => 'Beheben';

  @override
  String get fixMissingMetadata => 'Fehlende Metadaten beheben';

  @override
  String get fixedBands => '31 feste Bänder';

  @override
  String fixedCenterFrequenciesWithADb(Object arg1) {
    return 'Feste Mittenfrequenzen mit einem $arg1-dB-Bereich. Tippen Sie, um zu interagieren.';
  }

  @override
  String get flac24Bit96Khz => 'FLAC · 24-Bit / 96 kHz';

  @override
  String get flat => 'Flach';

  @override
  String get flatResponse => 'Flache Reaktion';

  @override
  String get flickCanAttemptToPreferA =>
      'Hadoo kann versuchen, einen bestimmten oben genannten Codec zu bevorzugen, der Erfolg hängt jedoch von Ihrem Gerät, Headset und der Android-Version ab. Die Codec-Erzwingung nutzt eine versteckte System-API und funktioniert möglicherweise nicht auf nicht gerooteten Geräten.';

  @override
  String get flickPreview => 'Hadoo Vorschau';

  @override
  String get flickReplay => 'Hadoo Wiederholung';

  @override
  String get flickWillForceYourChosenCodec =>
      'Hadoo erzwingt beim Herstellen der Verbindung den von Ihnen gewählten Codec';

  @override
  String get folder => 'Ordner';

  @override
  String get folderLimit => 'ORDNERBEGRENZUNG';

  @override
  String get folderName => 'Ordnername';

  @override
  String folderOf2(Object current, Object total) {
    return 'Ordner $current von $total';
  }

  @override
  String get folderSongCount => 'Anzahl der Ordnerlieder';

  @override
  String get folders => 'Ordner';

  @override
  String get foldersShownPerPage => 'Pro Seite angezeigte Ordner';

  @override
  String get fontScale => 'Schriftskala';

  @override
  String get footerLine => 'Fußzeile';

  @override
  String get forceDop => 'DoP erzwingen';

  @override
  String get forceDopAlwaysUseDsdOver =>
      'DoP erzwingen – Verwenden Sie immer DSD über PCM (USB DAC)';

  @override
  String get forcePcm => 'PCM erzwingen';

  @override
  String get forcePcmAlwaysConvertDsdTo =>
      'PCM erzwingen – Konvertieren Sie DSD immer in PCM';

  @override
  String get format => 'Format';

  @override
  String get formatControlsAreDisabledTheEngine =>
      'Formatsteuerelemente sind deaktiviert. Die Engine verwendet ihr Standardformat.';

  @override
  String get formatStrategy => 'Formatstrategie';

  @override
  String get formatStrategyAndCustomFormatControls =>
      'Formatstrategie und benutzerdefinierte Formatsteuerungen sind aktiv.';

  @override
  String get formatStrategyIsDisabledInBit =>
      'Die Formatierungsstrategie ist im Modus „Bit-perfekt“ (USB DAC) deaktiviert, da eine exakte Abtastratenanpassung erforderlich ist. Deaktivieren Sie Bit-Perfect (USB DAC), um die Formateinstellungen zu ändern.';

  @override
  String get formatStrategyIsUnavailableBecauseAudio =>
      'Die Formatierungsstrategie ist nicht verfügbar, da das Audioformat in den Einstellungen deaktiviert ist.';

  @override
  String foundOnline(Object arg1) {
    return '„$arg1“ online gefunden.';
  }

  @override
  String frPkt(Object arg1) {
    return '$arg1 ab/Pck';
  }

  @override
  String get freq => 'Freq';

  @override
  String get frequency => 'Häufigkeit';

  @override
  String get frequencyFocus => 'Frequenzfokus';

  @override
  String get freshAdditions => 'Neue Ergänzungen';

  @override
  String from(Object sourceLabel) {
    return 'Von $sourceLabel';
  }

  @override
  String get fromSquareCornersToARounded =>
      'Von eckigen Ecken bis hin zu abgerundeten Balken';

  @override
  String get fullBleedAlbumArtWithThe =>
      'Vollwertiges Albumcover im aktuellen Kino-Look.';

  @override
  String get fullPlayer => 'Voller Spieler';

  @override
  String get fullSpectrum => 'Volles Spektrum';

  @override
  String get fullViewCardSize => 'Vollbildkartengröße';

  @override
  String get fullViewCardSize2 => 'Vollbildkartengröße';

  @override
  String get fullscreen => 'Vollbild';

  @override
  String get fxOff => 'FX aus';

  @override
  String get fxOn => 'FX an';

  @override
  String get gain => 'Gewinn';

  @override
  String get gallery => 'Galerie';

  @override
  String get gapAboveNavigation => 'Lücke über der Navigation';

  @override
  String gb(Object arg1) {
    return '$arg1 GB';
  }

  @override
  String get generatedFromYourListeningHabitsFavorites =>
      'Erstellt aus Ihren Hörgewohnheiten, Favoriten und neuesten Ergänzungen.';

  @override
  String get genre => 'Genre';

  @override
  String get getStarted => 'Legen Sie los';

  @override
  String get getYourApiCredentials =>
      'Holen Sie sich Ihre API-Anmeldeinformationen';

  @override
  String get goToAlbum => 'Gehen Sie zum Album';

  @override
  String get goToArtist => 'Gehen Sie zu Künstler';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get grantBluetoothAccess => 'Gewähren Sie Bluetooth-Zugriff';

  @override
  String get graphic => 'Grafik';

  @override
  String get graphicEq => 'Grafischer EQ';

  @override
  String get green => 'Grün';

  @override
  String get groupingByTitleArtistThisIs =>
      'Gruppierung nach Titel und Künstler – das geht normalerweise schnell.';

  @override
  String get groups => 'Gruppen';

  @override
  String groupsToRemove(Object arg1, Object arg2) {
    return '$arg1-Gruppen • $arg2 zum Entfernen';
  }

  @override
  String groupsToRemove2(Object arg1, Object toRemove) {
    return '$arg1-Gruppen • $toRemove zum Entfernen';
  }

  @override
  String get growsFurtherIfLargerSystemText =>
      'Wächst weiter, wenn größerer Systemtext Platz benötigt';

  @override
  String hAgo(Object arg1) {
    return 'Vor ${arg1}h';
  }

  @override
  String get hardwareUsbDac => 'Hardware (USB-DAC)';

  @override
  String get hardwareVolumeIsDetectedButWrites =>
      'Die Hardware-Lautstärke wird erkannt, Schreibvorgänge bleiben jedoch blockiert, während die Live-Direkt-USB-Wiedergabe aktiv ist.';

  @override
  String get hasArtwork => 'Hat Kunstwerke';

  @override
  String get heavyRotation => 'Starke Rotation';

  @override
  String get held => 'Gehalten';

  @override
  String get hiResDirect => 'Hi-Res Direct';

  @override
  String get hideLyrics => 'Songtexte ausblenden';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get hideVisualizer => 'Visualizer ausblenden';

  @override
  String get hideVisualizer2 => 'Visualizer ausblenden';

  @override
  String get highFrequenciesOnly => 'Nur hohe Frequenzen';

  @override
  String get highPass => 'Hochpass';

  @override
  String get highQuality => 'Hohe Qualität';

  @override
  String get highQualityEngine => 'Hochwertiger Motor';

  @override
  String get highQualityWidelySupported =>
      'Hohe Qualität, breite Unterstützung';

  @override
  String get highResolutionAptx => 'Hochauflösendes aptX';

  @override
  String get highShelf => 'Hohes Regal';

  @override
  String get highestBitrateUpTo990Kbps => 'Höchste Bitrate (bis zu 990 kbps)';

  @override
  String get highestQuality => 'Höchste Qualität';

  @override
  String get historyCleared => 'Verlauf gelöscht';

  @override
  String hourUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stunden',
      one: 'Stunde',
    );
    return '$_temp0';
  }

  @override
  String get httpBasicNeedsItRecoverableStored =>
      'HTTP Basic muss wiederherstellbar sein; verschlüsselt gespeichert';

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
  String get hzTuning => '432-Hz-Tuning';

  @override
  String identified(int count, Object note) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return 'Identifiziert $_temp0$note.';
  }

  @override
  String get identifyAlbum => 'Album identifizieren';

  @override
  String get identifyAlbum2 => 'Album identifizieren';

  @override
  String get idle => 'Leerlauf';

  @override
  String get immersive => 'Immersiv';

  @override
  String importFailed(Object e) {
    return 'Import fehlgeschlagen: $e';
  }

  @override
  String get importM3uM3u8 => 'M3U/M3U8 importieren';

  @override
  String get importPresetFile => 'Preset-Datei importieren';

  @override
  String imported(Object arg1) {
    return 'Importiert „$arg1“';
  }

  @override
  String get importedArtIsSavedInsideThe =>
      'Importierte Grafiken werden in der App gespeichert und mit jedem Song in diesem Album synchronisiert.';

  @override
  String get importedArtIsSavedInsideThe2 =>
      'Importierte Grafiken werden nur für dieses Lied in der App gespeichert.';

  @override
  String importedWithSongs(Object arg1, Object arg2, Object unmatchedText) {
    return 'Importiert „$arg1“ mit $arg2-Songs.$unmatchedText';
  }

  @override
  String get impulseResponse => 'Impulsantwort';

  @override
  String inLabel(Object folder) {
    return 'in $folder';
  }

  @override
  String inYourLibrary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$_temp0 in Ihrer Bibliothek';
  }

  @override
  String get inactive => 'Inaktiv';

  @override
  String get incredibleOverAMonthOfDaily =>
      'Unglaublich – über einen Monat tägliches Hören.';

  @override
  String get inputGain => 'Eingangsverstärkung';

  @override
  String get inst => 'Inst';

  @override
  String get instructions => 'Anweisungen';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get interactiveEq => 'Interaktiver EQ';

  @override
  String get interfaceClaimed => 'Schnittstelle beansprucht';

  @override
  String get isochronousUsb => 'Isochroner USB';

  @override
  String items(Object count) {
    return '$count Artikel';
  }

  @override
  String get jan => 'Jan';

  @override
  String get jellyfin => 'Qualle';

  @override
  String get jellyfinEmby => 'Jellyfin · Emby';

  @override
  String get jul => 'Juli';

  @override
  String get jumpBackIn => 'Springen Sie wieder hinein';

  @override
  String get jun => 'Jun';

  @override
  String get justAudioExoplayer => 'just_audio / ExoPlayer';

  @override
  String get justAudioExoplayerDefault => 'just_audio / ExoPlayer (Standard)';

  @override
  String get justNow => 'Gerade eben';

  @override
  String get karaokePreview => 'Karaoke-Vorschau';

  @override
  String kb(Object arg1) {
    return '$arg1 KB';
  }

  @override
  String get keepAll => 'Behalten Sie alle';

  @override
  String get keepEditing => 'Bearbeiten Sie weiter';

  @override
  String get keepItGoingOpenTomorrowTo =>
      'Weiter so. Morgen geöffnet, um einen weiteren Tag hinzuzufügen.';

  @override
  String get keepListeningWithFlick => 'Hören Sie weiter mit Hadoo';

  @override
  String get keepPlaybackPausedWhenADevice =>
      'Halten Sie die Wiedergabe angehalten, wenn ein Gerät erneut eine Verbindung herstellt';

  @override
  String get keepTheSessionMovingOrHead =>
      'Halten Sie die Sitzung am Laufen oder gehen Sie direkt zurück zum Player.';

  @override
  String get keepYourReplay => 'Behalten Sie Ihre Wiederholung.';

  @override
  String keeping(Object type, Object br) {
    return 'Behalten • $type • $br';
  }

  @override
  String keepingOfToRemove(Object keptCount, Object arg1, Object removeCount) {
    return 'Behalten Sie $keptCount von $arg1 • $removeCount zum Entfernen';
  }

  @override
  String get keepingThisVersion => 'Behalte diese Version';

  @override
  String get keepsSoftwareVolumeAndDspActive =>
      'Hält Software-Lautstärke und DSP auf dem gemeinsam genutzten DAP-Pfad aktiv.';

  @override
  String get keptInSecureStorageToRe =>
      'Wird im sicheren Speicher aufbewahrt, damit Sie sich nach Ablauf des Tokens erneut anmelden können';

  @override
  String keptWillBeRemoved(Object keptCount, Object removeCount) {
    return '$keptCount bleibt erhalten • $removeCount wird entfernt';
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
  String get label => 'Label';

  @override
  String get labelOrganization => 'Etikett / Organisation';

  @override
  String get lastFm => 'Last.fm';

  @override
  String get lastFmConfiguration => 'Last.fm-Konfiguration';

  @override
  String get lastFmConnected => 'Last.fm Verbunden';

  @override
  String get lastFmConnected2 => 'Last.fm verbunden!';

  @override
  String get lastPick => 'Letzte Wahl';

  @override
  String get lastWeek => 'Letzte Woche';

  @override
  String get lateNightSessions => 'Late-Night-Sessions';

  @override
  String get latestArrivalsFromYourLibrary => 'Neuzugänge aus Ihrer Bibliothek';

  @override
  String get layered => 'Geschichtet';

  @override
  String get layoutMode => 'Layoutmodus';

  @override
  String get ldac330Kbps => 'LDAC 330 kbit/s';

  @override
  String get ldac660Kbps => 'LDAC 660 kbit/s';

  @override
  String get ldac990Kbps => 'LDAC 990 kbit/s';

  @override
  String get ldacAdaptive => 'LDAC Adaptiv';

  @override
  String get ldacBitsPerSample => 'LDAC-Bits pro Probe';

  @override
  String get leLsbLittleEndianSubslotLsb =>
      'LE-LSB – Little-Endian-Subslot, LSB zuerst';

  @override
  String get leMsbLittleEndianSubslotMsb =>
      'LE-MSB – Little-Endian-Subslot, MSB zuerst';

  @override
  String get leaveEmptyToKeepTheCurrent =>
      'Lassen Sie das Feld leer, um die aktuellen Anmeldeinformationen beizubehalten';

  @override
  String get leftBottom => 'Links (unten)';

  @override
  String get leftBottomButton => 'Linke (untere) Taste';

  @override
  String get leftTop => 'Links (oben)';

  @override
  String get leftTopButton => 'Linke (oben) Taste';

  @override
  String get length => 'Länge:';

  @override
  String lengthS(Object arg1) {
    return 'Länge ${arg1}s';
  }

  @override
  String get letAndroidChooseTheBestCodec =>
      'Lassen Sie Android den besten Codec auswählen';

  @override
  String get letAndroidChooseTheOutputDevice =>
      'Lassen Sie Android das Ausgabegerät auswählen';

  @override
  String get letAndroidNegotiateTheCodecAutomatically =>
      'Lassen Sie Android den Codec automatisch aushandeln';

  @override
  String get letOboePickTheBestApi =>
      'Lassen Sie Oboe die beste API auswählen. Zuerst AAudio, dann OpenSL ES-Fallback.';

  @override
  String get letSTakeAQuickTour =>
      'Machen wir einen kurzen Rundgang durch Ihren neuen Musikplayer.';

  @override
  String get libraryLabel => 'Mediathek';

  @override
  String get light => 'Licht';

  @override
  String likedSongs(Object arg1) {
    return '$arg1 mochte Lieder';
  }

  @override
  String get likedSongsLiveHere => 'Lieblingslieder live hier';

  @override
  String get likesAndReplaysBlendedTogether =>
      'Likes und Replays vermischten sich';

  @override
  String get limit => 'Limit';

  @override
  String get limiter => 'Begrenzer';

  @override
  String get limiterOff => 'Limiter aus';

  @override
  String get limiterOn => 'Begrenzer eingeschaltet';

  @override
  String get line => 'Linie';

  @override
  String lineOf(Object arg1, Object arg2) {
    return 'Zeile $arg1 von $arg2';
  }

  @override
  String lineOfWords(
    Object arg1,
    Object arg2,
    Object captured,
    Object segmentCount,
  ) {
    return 'Zeile $arg1 der Wörter $arg2 · $captured/$segmentCount';
  }

  @override
  String get lines => 'Linien';

  @override
  String lines2(Object arg1) {
    return '$arg1-Zeilen';
  }

  @override
  String get linkReady => 'Link bereit';

  @override
  String linkedToThisSong(Object arg1) {
    return '„$arg1“ mit diesem Lied verknüpft.';
  }

  @override
  String get list => 'Liste';

  @override
  String get listAvailableLocalAudioOutputDevices =>
      'Verfügbare lokale Audioausgabegeräte auflisten';

  @override
  String get listenbrainz => 'ListenBrainz';

  @override
  String get listenbrainzConnected => 'ListenBrainz Verbunden';

  @override
  String get listenbrainzConnected2 => 'ListenBrainz verbunden!';

  @override
  String get listeningHours => 'Hörstunden';

  @override
  String listeningToByOnFlick(Object arg1, Object arg2) {
    return 'Hören Sie $arg1 von $arg2 auf Hadoo';
  }

  @override
  String get littleEndianSubslotLsbFirstBits =>
      'Little-Endian-Subslot, LSB-erste Bits';

  @override
  String get littleEndianSubslotMsbFirstBits =>
      'Little-Endian-Subslot, MSB-erste Bits';

  @override
  String get livePreview => 'Live-Vorschau';

  @override
  String get livingOrnament => 'Lebendiges Ornament';

  @override
  String get loadAJsonOrTxtPreset =>
      'Laden Sie eine JSON- oder TXT-Voreinstellung';

  @override
  String get loadAnImpulseResponseForRoom =>
      'Laden Sie eine Impulsantwort für Raumhall, Crossfeed, Box oder Korrektur.';

  @override
  String get loadIr => 'IR laden';

  @override
  String loadedIr(Object displayName) {
    return 'Geladene IR: $displayName';
  }

  @override
  String get loadingArtwork2 => 'Bildmaterial wird geladen…';

  @override
  String get loadingFavoritesRecentSessionsGenerated =>
      'Laden von Favoriten, letzten Sitzungen, generierten Mixen und Wiedergabelisten.';

  @override
  String get loadingReplay => 'Wiedergabe wird geladen';

  @override
  String get loadingSession => 'Sitzung wird geladen...';

  @override
  String get locked => 'Gesperrt';

  @override
  String get logFrequencyControl => 'Protokollfrequenzkontrolle';

  @override
  String get logs => 'Protokolle';

  @override
  String get logsCopied => 'Protokolle kopiert';

  @override
  String get longSongTitles => 'Lange Songtitel';

  @override
  String get look => 'Schauen Sie';

  @override
  String get lookingForCoverArtFromMusicbrainz =>
      'Auf der Suche nach Cover-Art von MusicBrainz und Cover Art Archive.';

  @override
  String get lossless => ' Verlustfrei';

  @override
  String get losslessQualityPreservedDuringConversion =>
      'Verlustfreie Qualität bleibt bei der Konvertierung erhalten';

  @override
  String get lowAndHighFrequenciesScoopedMids =>
      'Tiefe und hohe Frequenzen, gewölbte Mitten';

  @override
  String get lowFrequenciesOnly => 'Nur niedrige Frequenzen';

  @override
  String get lowLatencyGoodQuality => 'Geringe Latenz, gute Qualität';

  @override
  String get lowLatencyMode => 'Modus mit geringer Latenz';

  @override
  String get lowPass => 'Tiefpass';

  @override
  String get lowShelf => 'Niedriges Regal';

  @override
  String get lrclib => 'LRCLib';

  @override
  String get lyric => 'Lyrik';

  @override
  String get lyrics => 'Songtexte';

  @override
  String get lyricsPreview => 'Songtext-Vorschau';

  @override
  String get lyricsSavedFromLrclib => 'Liedtext aus LRCLib gespeichert.';

  @override
  String get lyricsSyncHelp => 'Songtext-Sync-Hilfe';

  @override
  String get lyricsSyncStudio => 'Lyrics Sync Studio';

  @override
  String get lyricsText => 'Liedtext';

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
    return 'Vor ${arg1}m';
  }

  @override
  String get madeForYou => 'Für Sie gemacht';

  @override
  String get makeup => 'Make-up';

  @override
  String get manualOrder => 'Manuelle Bestellung';

  @override
  String get manualQueue => 'Manuelle Warteschlange';

  @override
  String get manufacturer => 'Hersteller';

  @override
  String get mar => 'März';

  @override
  String get masterBypassed => 'Meister umgangen';

  @override
  String matchByArtistAlbumAndTrack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Dateien',
      one: '$count-Datei',
    );
    return 'Spiel $_temp0 nach Künstler, Album und Titellänge';
  }

  @override
  String get matchEqToYourHeadphoneModel =>
      'Passen Sie den EQ an Ihr Kopfhörermodell an';

  @override
  String get matchNavigation => 'Match-Navigation';

  @override
  String get matches => 'Streichhölzer';

  @override
  String maxB(Object arg1) {
    return 'Max $arg1 B';
  }

  @override
  String get maximumAudioQuality => 'Maximale Audioqualität';

  @override
  String get may => 'Mai';

  @override
  String mb(Object arg1) {
    return '$arg1 MB';
  }

  @override
  String get medium => 'Mittel';

  @override
  String get menu => 'Menü';

  @override
  String get metropolitan => 'Metropolit';

  @override
  String mhz(Object arg1) {
    return '$arg1 MHz';
  }

  @override
  String get mid => 'Mitte';

  @override
  String get midFrequenciesOnly => 'Nur mittlere Frequenzen';

  @override
  String get midnightCityDreams => 'Mitternachtsstadtträume';

  @override
  String get midnightSignal => 'Mitternachtssignal';

  @override
  String get milestone => 'Meilenstein';

  @override
  String get milestones => 'Meilensteine';

  @override
  String min(Object arg1) {
    return '$arg1 min';
  }

  @override
  String get miniPlayer => 'Mini-Player';

  @override
  String get miniPlayerAppearance => 'Aussehen des Minispielers';

  @override
  String get miniPlayerDefaultsRestored =>
      'Die Standardeinstellungen des Miniplayers wurden wiederhergestellt';

  @override
  String get miniPlayerHeight => 'Mini-Player-Höhe';

  @override
  String get miniPlayerLayout => 'Mini-Player-Layout';

  @override
  String get minimal => 'Minimal';

  @override
  String get minimserverServiioKodi => 'MinimServer · Server · Kodi';

  @override
  String get mirrorTest => 'Spiegeltest';

  @override
  String get mirrored => 'Gespiegelt';

  @override
  String get mitLicenseCopyrightC2026Flick =>
      '\nMIT-Lizenz\n\nUrheberrecht (c) 2026 Flick Spieler-Mitwirkende\n\nHiermit wird jeder Person, die eine Kopie erhält, kostenlos die Erlaubnis erteilt\ndieser Software und der zugehörigen Dokumentationsdateien (die „Software“) zu handeln\nan der Software ohne Einschränkung, einschließlich und ohne Einschränkung der Rechte\nzum Verwenden, Kopieren, Modifizieren, Zusammenführen, Veröffentlichen, Verteilen, Unterlizenzieren und/oder Verkaufen\nKopien der Software zu erwerben und Personen zu gestatten, denen die Software gehört\nunter folgenden Bedingungen zur Verfügung gestellt:\n\nDer obige Urheberrechtshinweis und dieser Genehmigungshinweis sind in allen Bestandteilen enthalten\nKopien oder wesentliche Teile der Software.\n\nDIE SOFTWARE WIRD „WIE BESEHEN“ ZUR VERFÜGUNG GESTELLT, OHNE JEGLICHE AUSDRÜCKLICHE ODER GEWÄHRLEISTUNG\nSTILLSCHWEIGEND, EINSCHLIESSLICH, ABER NICHT BESCHRÄNKT AUF DIE GARANTIEN DER MARKTGÄNGIGKEIT,\nEIGNUNG FÜR EINEN BESTIMMTEN ZWECK UND NICHTVERLETZUNG. IN KEINEM FALL DÜRFEN DIE\nDie Autoren oder Urheberrechtsinhaber haften für Ansprüche, Schäden oder sonstiges\nHAFTUNG, SEI ES AUS EINEM VERTRAG, EINER HANDLUNG AUS VERLETZLICHER HANDLUNG ODER ANDERWEITIG, ENTSTEHEND AUS:\nAUS ODER IN VERBINDUNG MIT DER SOFTWARE ODER DER NUTZUNG ODER ANDEREN HANDELN IN DER\nSOFTWARE.\n';

  @override
  String get mix => 'Mischen';

  @override
  String mix2(Object arg1) {
    return 'Mischen Sie $arg1';
  }

  @override
  String get mixer => 'Mischer';

  @override
  String get mixerManagement => 'Mixer-Management';

  @override
  String moAgo(Object arg1) {
    return 'Vor ${arg1}mo';
  }

  @override
  String get moderate => 'Mäßig';

  @override
  String get mono => 'Mono';

  @override
  String get monthly => 'Monatlich';

  @override
  String get more => 'Mehr';

  @override
  String more2(Object arg1, Object arg2) {
    return '$arg1 + $arg2 mehr';
  }

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get moreArtists => 'Weitere Künstler';

  @override
  String get moreArtists2 => 'Weitere Künstler';

  @override
  String get moreExportOptions => 'Weitere Exportoptionen';

  @override
  String moreFrom(Object arg1) {
    return 'Mehr von $arg1';
  }

  @override
  String get moreFromArtist => 'Mehr vom Künstler';

  @override
  String moreTo(Object arg1, Object arg2) {
    return '$arg1 mehr zu $arg2';
  }

  @override
  String moreToUnlock(Object remaining, Object unit) {
    return '$remaining weitere $unit zum Freischalten.';
  }

  @override
  String get mostDlnaServersNeedNoPassword =>
      'Die meisten DLNA-Server benötigen kein Passwort';

  @override
  String get mostPlayed => 'Am häufigsten gespielt';

  @override
  String mostReplayed(Object arg1) {
    return 'Am häufigsten wiedergegeben · $arg1';
  }

  @override
  String get motionArtRefreshed => 'Bewegungskunst aufgefrischt';

  @override
  String get moveEveryStampedLyricForwardOr =>
      'Bewegen Sie jeden gestempelten Liedtext gemeinsam vorwärts oder rückwärts.';

  @override
  String get movement => 'Bewegung';

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
  String get multiFilterBands => 'Multifilterbänder';

  @override
  String musicFolders(Object arg1) {
    return '$arg1 Musikordner';
  }

  @override
  String get mute => 'Stumm';

  @override
  String my(Object arg1) {
    return 'Mein $arg1';
  }

  @override
  String nDb(Object arg1, Object arg2) {
    return '$arg1%\n$arg2 dB';
  }

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String narrow(Object amount) {
    return '$amount% schmal';
  }

  @override
  String get nativeDsd => 'Natives DSD';

  @override
  String get nativeDsdExperimental => 'Natives DSD (experimentell)';

  @override
  String get nativeDsdExperimentalMayBeBuggy =>
      'Natives DSD – experimentell (möglicherweise fehlerhaft)';

  @override
  String get naturalEqualizerFeelResponsiveYetSmooth =>
      'Natürliches Equalizer-Feeling – reaktionsschnell und dennoch flüssig';

  @override
  String get natureAmbient => 'Naturambiente';

  @override
  String get navidromeAirsonicGonic => 'Navidrome · Airsonic · Gonic';

  @override
  String get navigationBar => 'Navigationsleiste';

  @override
  String get needsMetadata => 'Benötigt Metadaten';

  @override
  String negotiated(Object arg1) {
    return 'Verhandelt: $arg1';
  }

  @override
  String get neonNights => 'Neonnächte';

  @override
  String get neonSkyline => 'Neon-Skyline';

  @override
  String get network => 'Netzwerk';

  @override
  String get networkSources => 'Netzwerkquellen';

  @override
  String neutral(Object amount) {
    return '$amount% neutral';
  }

  @override
  String get neverSynced => 'Noch nie synchronisiert';

  @override
  String get next => 'Weiter';

  @override
  String get nextSong => 'Nächstes Lied';

  @override
  String get nextSong2 => 'Nächstes Lied';

  @override
  String nextToGo(Object arg1, Object remaining, Object unit) {
    return 'Als nächstes: $arg1 – $remaining $unit zum Mitnehmen';
  }

  @override
  String get nextcloudOwncloudSabredav => 'Nextcloud · ownCloud · SabreDAV';

  @override
  String get night => 'Nacht';

  @override
  String get no => 'Nein';

  @override
  String get noAlbumDataYet => 'Noch keine Albumdaten';

  @override
  String get noAlbumsFound => 'Keine Alben gefunden';

  @override
  String get noAppleMusicReleaseFoundTry =>
      'Keine Apple Music-Version gefunden. Versuchen Sie, den Künstler- oder Albumnamen zu bearbeiten und erneut zu suchen.';

  @override
  String get noArtistsFound => 'Keine Künstler gefunden';

  @override
  String noArtistsMatch(Object _searchQuery) {
    return 'Kein Künstler passt zu „$_searchQuery“';
  }

  @override
  String get noCastingDevicesFoundMakeSure =>
      'Keine Casting-Geräte gefunden. Stellen Sie sicher, dass sich Ihr Telefon und der Receiver im selben Netzwerk befinden.';

  @override
  String get noCategoriesSelected => 'Keine Kategorien ausgewählt';

  @override
  String get noChangelogNotesForThisVersion =>
      'Für diese Version liegen noch keine Änderungsprotokollnotizen vor.';

  @override
  String get noCustomPresetsYet =>
      'Noch keine benutzerdefinierten Voreinstellungen.';

  @override
  String get noDuplicatesFound => 'Keine Duplikate gefunden';

  @override
  String get noFavoritesYet => 'Noch keine Favoriten';

  @override
  String get noFeaturedTrackYet => 'Noch kein vorgestellter Titel';

  @override
  String get noFoldersAdded => 'Keine Ordner hinzugefügt';

  @override
  String get noHistoryYet => 'Noch keine Geschichte';

  @override
  String get noInternetConnectionPleaseCheckYour =>
      'Keine Internetverbindung. Bitte überprüfen Sie Ihr Netzwerk und versuchen Sie es erneut.';

  @override
  String get noLogsYet => 'Noch keine Protokolle.';

  @override
  String get noLyricsFoundOnlineForThis =>
      'Für dieses Lied wurde kein Text online gefunden.';

  @override
  String get noLyricsYet => 'Noch kein Liedtext';

  @override
  String get noMatchFound => 'Keine Übereinstimmung gefunden';

  @override
  String get noMatches => 'Keine Übereinstimmungen.';

  @override
  String noMatchesFor(Object _query) {
    return 'Keine Treffer für „$_query“';
  }

  @override
  String get noMatchesFound => 'Keine Übereinstimmungen gefunden';

  @override
  String get noMatchesTryFewerWordsOr =>
      'Keine Übereinstimmungen. Versuchen Sie es mit weniger Wörtern oder suchen Sie online.';

  @override
  String get noMusicYet => 'Noch keine Musik';

  @override
  String get noNewAdditionsYet => 'Noch keine Neuzugänge';

  @override
  String get noOnlineArtworkFound => 'Kein Online-Kunstwerk gefunden';

  @override
  String get noOutputDevicesAvailable => 'Keine Ausgabegeräte verfügbar.';

  @override
  String get noPlaybackYet => 'Noch keine Wiedergabe';

  @override
  String get noPlaylistsYet => 'Noch keine Playlists';

  @override
  String get noPlaylistsYet2 => 'Noch keine Playlists';

  @override
  String get noPlaylistsYetNcreateOneIn =>
      'Noch keine Playlists.\nErstellen Sie eine auf der Registerkarte „Playlists“.';

  @override
  String get noRankingDataYet => 'Noch keine Ranking-Daten';

  @override
  String noResultsFor(Object query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String noResultsFoundFor(Object query) {
    return 'Für „$query“ wurden keine Ergebnisse gefunden.';
  }

  @override
  String get noRipData => 'Keine Rip-Daten';

  @override
  String get noScanResultsYet => 'Noch keine Scan-Ergebnisse';

  @override
  String get noServerPlaylistsFound => 'Keine Server-Playlists gefunden';

  @override
  String get noServersConnected => 'Keine Server verbunden';

  @override
  String get noSongPlaying => 'Es wird kein Lied abgespielt';

  @override
  String get noSongsFound => 'Keine Songs gefunden';

  @override
  String get noSongsInThisPlaylist => 'Keine Songs in dieser Playlist';

  @override
  String get noUpcomingQueueItemsYet =>
      'Noch keine bevorstehenden Warteschlangenelemente.';

  @override
  String get noUrbData => 'Keine URB-Daten';

  @override
  String get noUsbAudioDevicesFound => 'Keine USB-Audiogeräte gefunden';

  @override
  String get noWordTimingYetAutoFill =>
      'Noch kein Wort-Timing. Beim automatischen Ausfüllen werden die Wörter als Ausgangspunkt gleichmäßig verteilt – oder Sie erfassen sie im Word-Sync-Modus.';

  @override
  String get none => 'Keine';

  @override
  String get notAnAlacFile => 'Keine ALAC-Datei';

  @override
  String get notFoundOnlineTryADifferent =>
      'Nicht online gefunden. Versuchen Sie es mit einer anderen Schreibweise.';

  @override
  String get notHeld => 'Nicht gehalten';

  @override
  String get notRecommendedForNormalUsageDsd =>
      'Für den normalen Gebrauch nicht empfohlen. Die DSD-Wiedergabe ist instabil und kann zu Audiostörungen führen.';

  @override
  String get notRegistered => 'Nicht registriert';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get notStampedYet => 'Noch nicht gestempelt';

  @override
  String get notVerified => 'Nicht bestätigt';

  @override
  String get notch => 'Kerbe';

  @override
  String get notchDepth => 'Kerbtiefe';

  @override
  String get noticeableTintingFromAlbumArt =>
      'Auffällige Tönung durch Albumcover.';

  @override
  String get nov => 'Nov';

  @override
  String get now => 'Jetzt';

  @override
  String get nowPlaying => 'Aktuelle Wiedergabe';

  @override
  String get nowPlaying2 => 'Wird gerade abgespielt';

  @override
  String get numberOnArt => 'Nummer auf Kunst';

  @override
  String get oauthSignInNoPasswordStored =>
      'OAuth-Anmeldung; Hier ist kein Passwort hinterlegt';

  @override
  String get oceanWaves => 'Meereswellen';

  @override
  String get oct => 'Okt';

  @override
  String get off => 'Aus';

  @override
  String get onAndroidTheStandardJustAudio =>
      'Unter Android wendet der standardmäßige just_audio-Wiedergabepfad jetzt native Gegenstücke für EQ, Dynamik, Balance und räumliche Effekte auf unterstützten Geräten an. Die Rust-Engine liefert immer noch die genaueste Version dieser Steuerelemente, daher sind einige Android-Ergebnisse ungefähre Werte.';

  @override
  String get onRepeat => 'Bei Wiederholung';

  @override
  String get onlineResults => 'Online-Ergebnisse';

  @override
  String get onlyLibraryEntriesAreRemovedYour =>
      'Es werden nur Bibliothekseinträge entfernt – Ihre Audiodateien bleiben auf der Festplatte.';

  @override
  String get open => 'Offen';

  @override
  String get openAndroidSettings => 'Öffnen Sie die Android-Einstellungen';

  @override
  String get openBluetoothCodecSettings =>
      'Öffnen Sie die Bluetooth-Codec-Einstellungen';

  @override
  String get openInAppleMusic => 'Öffnen Sie in Apple Music';

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String get openLibrary => 'Bibliothek öffnen';

  @override
  String get openListenbrainzOrgSettings =>
      'Öffnen Sie listenbrainz.org/settings';

  @override
  String get openManual => 'Handbuch öffnen';

  @override
  String get openPlayer => 'Öffnen Sie den Player';

  @override
  String get openedFromLocker => 'Vom Schließfach aus geöffnet';

  @override
  String get openslEs => 'OpenSL ES';

  @override
  String get openslEsLegacy => 'OpenSL ES (Legacy)';

  @override
  String get orRemoveAllUsingRecommendedPicks =>
      'Oder entfernen Sie alles mit den empfohlenen Picks';

  @override
  String get orbital => 'Orbital';

  @override
  String get otherPlaylists => 'Andere Playlists';

  @override
  String get ourRustPoweredEngineCleanerSound =>
      'Unser von Rust angetriebener Motor. Klarerer Klang und flüssigere Wiedergabe – empfohlen für das tägliche Hören.';

  @override
  String get outlineTheMiniPlayer => 'Skizzieren Sie den Miniplayer';

  @override
  String get output => 'Ausgabe';

  @override
  String get outputDevice => 'Ausgabegerät';

  @override
  String get outputMode => 'Ausgabemodus';

  @override
  String get outputRate => 'Ausgaberate';

  @override
  String get overviewMetricsChooseUpTo3 =>
      'Übersichtsmetriken · Wählen Sie bis zu 3 aus';

  @override
  String get paired => 'Gepaart';

  @override
  String get parametric => 'Parametrisch';

  @override
  String parametricBandsWithIndependentFrequency(Object arg1) {
    return '$arg1 parametrische Bänder mit unabhängiger Frequenz, Verstärkung und Q-Formung. Tippen Sie, um zu interagieren.';
  }

  @override
  String get parametricEq => 'Parametrischer EQ';

  @override
  String get passthrough => 'Passthrough';

  @override
  String get password => 'Passwort';

  @override
  String get pasteOrTypeTheSongLyrics =>
      'Fügen Sie hier den Songtext ein oder geben Sie ihn ein – eine Zeile pro Zeile';

  @override
  String get pasteYourListenbrainzToken =>
      'Fügen Sie Ihr ListenBrainz-Token ein';

  @override
  String get pause => 'Pausieren';

  @override
  String get pauseOnBluetoothConnect => 'Pause bei Bluetooth-Verbindung';

  @override
  String get pauseOnDisconnect => 'Pause beim Trennen';

  @override
  String get pauseOnUsbDacAttach => 'Pause bei USB-DAC-Anschluss';

  @override
  String get pauseOnUsbDacDetach => 'Pause beim Trennen des USB-DAC';

  @override
  String get pcmFrames => 'PCM-Rahmen';

  @override
  String get peakHour => 'Hauptverkehrszeit';

  @override
  String get peaking => 'Höhepunkt';

  @override
  String get permission => 'Erlaubnis';

  @override
  String get personalPlaylist => 'Persönliche Playlist';

  @override
  String get phoneAndHeadsetVolumeAreIndependent =>
      'Telefon- und Headset-Lautstärke sind unabhängig';

  @override
  String get phoneAndHeadsetVolumeAreLinked =>
      'Telefon- und Headset-Lautstärke sind gekoppelt';

  @override
  String get photoFraming => 'Fotorahmen';

  @override
  String get pickALineWithLyrics => 'Wählen Sie eine Zeile mit Text';

  @override
  String get pickALyricLineIn =>
      '1. Wählen Sie unter „Zeilen“ eine Textzeile aus und wechseln Sie dann zu „Tools.\n2“. Drücken Sie die Wiedergabetaste und tippen Sie auf die große Schaltfläche „Wort tippen“, während Sie jedes Wort hören – beim ersten Tippen wird auch die Zeile gestempelt.\n3. Tippen Sie auf einen Wortchip, um ihn zu verschieben, die Zeit neu zu bestimmen oder zu löschen.\n4. Zeilen, in denen jedes Wort gestempelt ist, mit Karaoke-Timing pro Wort.';

  @override
  String get pickAgain => 'Wählen Sie noch einmal';

  @override
  String get pickImage => 'Wählen Sie Bild';

  @override
  String get pickUpExactlyWhereYourLast =>
      'Machen Sie genau dort weiter, wo Ihre letzten Sitzungen aufgehört haben.';

  @override
  String get pinchApartNarrowerHigherQNpinch =>
      'Auseinanderdrücken = schmaler (höheres Q)\nZusammendrücken = breiter (niedrigeres Q)';

  @override
  String get pitch => 'Tonhöhe';

  @override
  String pitchSemitones(int semitones) {
    String _temp0 = intl.Intl.pluralLogic(
      semitones,
      locale: localeName,
      other: '$semitones Halbtöne',
      one: '$semitones Halbton',
    );
    return '$_temp0';
  }

  @override
  String get plain => 'Einfach';

  @override
  String get plainText => 'Klartext';

  @override
  String get play => 'Abspielen';

  @override
  String get playAFewSongsAndThis =>
      'Spielen Sie ein paar Songs ab und diese Seite beginnt sich mit Mixen, Künstlern und Verknüpfungen zu füllen.';

  @override
  String get playAFewTracksTodayTo =>
      'Spielen Sie heute ein paar Titel, um Ihre tägliche Zusammenfassung zusammenzustellen.';

  @override
  String get playAgain => 'Spielen Sie noch einmal';

  @override
  String get playBadges => 'Spielabzeichen';

  @override
  String get playCategoriesInRandomOrderTracks =>
      'Spielen Sie Kategorien in zufälliger Reihenfolge und Titel nacheinander ab';

  @override
  String get playInOrder => 'Spielen Sie der Reihe nach';

  @override
  String get playNext => 'Als Nächstes abspielen';

  @override
  String get playbackContinuesWhenABluetoothDevice =>
      'Die Wiedergabe wird fortgesetzt, wenn ein Bluetooth-Gerät eine Verbindung herstellt';

  @override
  String get playbackContinuesWhenAUsbDac =>
      'Die Wiedergabe wird fortgesetzt, wenn ein USB-DAC angeschlossen ist';

  @override
  String get playbackContinuesWhenAUsbDac2 =>
      'Die Wiedergabe wird fortgesetzt, wenn ein USB-DAC ausgesteckt wird';

  @override
  String get playbackContinuesWhenAudioOutput =>
      'Die Wiedergabe wird fortgesetzt, wenn die Audioausgabe unterbrochen wird';

  @override
  String get playbackEngine => 'Wiedergabe-Engine';

  @override
  String get playbackIsUsingAndroidManagedOutput =>
      'Die Wiedergabe erfolgt über eine von Android verwaltete Ausgabe und kann neu abgetastet werden.';

  @override
  String get playbackIsUsingTheStandardAndroid =>
      'Die Wiedergabe erfolgt über den standardmäßigen Android-Ausgabepfad.';

  @override
  String get playbackModeWillUpdateAfterThe =>
      'Der Wiedergabemodus wird nach der nächsten Route oder Wiedergabeaktualisierung aktualisiert.';

  @override
  String get playbackPath => 'Wiedergabepfad';

  @override
  String get playbackPausesWhenABluetoothAudio =>
      'Die Wiedergabe wird angehalten, wenn ein Bluetooth-Audiogerät eine Verbindung herstellt';

  @override
  String get playbackPausesWhenAUsbDac =>
      'Die Wiedergabe wird angehalten, wenn ein USB-DAC angeschlossen ist';

  @override
  String get playbackPausesWhenAUsbDac2 =>
      'Die Wiedergabe wird angehalten, wenn ein USB-DAC physisch getrennt wird';

  @override
  String get playbackPausesWhenBluetoothOrHeadphones =>
      'Die Wiedergabe wird angehalten, wenn Bluetooth oder Kopfhörer getrennt werden';

  @override
  String get playbackResumesWhenADeviceReconnects =>
      'Die Wiedergabe wird fortgesetzt, wenn ein Gerät innerhalb von 30 Sekunden wieder eine Verbindung herstellt';

  @override
  String get playbackSpeed => 'Wiedergabegeschwindigkeit';

  @override
  String played(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$_temp0 gespielt';
  }

  @override
  String get playerLayout => 'Spielerlayout';

  @override
  String playlist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Wiedergabelisten',
      one: '$count-Wiedergabeliste',
    );
    return '$_temp0';
  }

  @override
  String get playlist2 => 'Wiedergabeliste';

  @override
  String playlistCreated(Object arg1) {
    return 'Playlist „$arg1“ erstellt';
  }

  @override
  String get playlistName => 'Playlistname';

  @override
  String get playlists => 'Wiedergabelisten';

  @override
  String plays(Object arg1) {
    return '$arg1 spielt';
  }

  @override
  String plays2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spielt',
      one: '1 Stück',
    );
    return '$_temp0';
  }

  @override
  String get playsInRotation => 'spielt im Wechsel';

  @override
  String get pleaseEnterAPlaylistName => 'Gib einen Playlist-Namen ein';

  @override
  String get pleaseEnterYourListenbrainzUserToken =>
      'Bitte geben Sie Ihr ListenBrainz-Benutzertoken ein.';

  @override
  String posterPreviewPlays(Object arg1, Object arg2) {
    return '$arg1 Postervorschau. $arg2 spielt.';
  }

  @override
  String get preamp => 'Vorverstärker';

  @override
  String get preloadingAudio3 => 'Audio wird vorab geladen';

  @override
  String get preparing => 'Vorbereiten…';

  @override
  String get presence => 'Präsenz';

  @override
  String preset(Object activePresetName) {
    return 'Voreinstellung: $activePresetName';
  }

  @override
  String get presetImportedWithAdjustments =>
      'Voreinstellung mit Anpassungen importiert';

  @override
  String get presetName => 'Voreingestellter Name';

  @override
  String get presets => 'Voreinstellungen';

  @override
  String get preview => 'Vorschau';

  @override
  String get previewUse => 'Vorschau und Verwendung';

  @override
  String get previousSong => 'Vorheriges Lied';

  @override
  String get previousSong2 => 'Vorheriges Lied';

  @override
  String get prewarming => 'Vorwärmen';

  @override
  String get prioritiseConnectionStability =>
      'Priorisieren Sie die Verbindungsstabilität';

  @override
  String get processingLive => 'Live-Verarbeitung';

  @override
  String get product => 'Produkt';

  @override
  String get productId => 'Produkt-ID';

  @override
  String get progress => 'Fortschritt';

  @override
  String get protocol => 'Protokoll';

  @override
  String get pulledFromYourLateSessionPlays =>
      'Aus Ihren Spielen in der späten Sitzung';

  @override
  String get purple => 'Lila';

  @override
  String get queue => 'Warteschlange';

  @override
  String queue2(Object count) {
    return 'Warteschlange $count';
  }

  @override
  String get queueIsEmpty => 'Warteschlange ist leer';

  @override
  String queued(Object arg1) {
    return 'In der Warteschlange „$arg1“';
  }

  @override
  String queuedSongs(Object arg1) {
    return 'In der Warteschlange befindliche $arg1-Songs';
  }

  @override
  String queuedSongs3(Object arg1) {
    return 'In der Warteschlange befindliche $arg1-Songs';
  }

  @override
  String get quickActions => 'Schnelle Aktionen';

  @override
  String get random => 'Zufällig';

  @override
  String get rating => 'Bewertung';

  @override
  String get ratio => 'Verhältnis';

  @override
  String get rawDsdStreamToDacRequires =>
      'Roher DSD-Stream zum DAC. Erfordert ENCODING_DSD-Hardwareunterstützung; Andernfalls wird automatisch auf DoP oder PCM zurückgegriffen.';

  @override
  String get rawPcm => '→ Rohes PCM';

  @override
  String get readMode => 'Lesemodus';

  @override
  String get readingTheCoverColors => 'Lesen Sie die Coverfarben…';

  @override
  String readyToRemoveSongKeepingIn(int count, Object kept) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return 'Bereit zum Entfernen $_temp0 — $kept insgesamt beibehalten.';
  }

  @override
  String recapSavedAs(Object format) {
    return 'Zusammenfassung gespeichert als $format';
  }

  @override
  String recentPicksOnHand(Object arg1) {
    return '$arg1 Aktuelle Auswahl zur Hand';
  }

  @override
  String get recentlyAdded => 'Kürzlich hinzugefügt';

  @override
  String get recentlyAddedTracksWaitingForMore =>
      'Kürzlich hinzugefügte Titel warten auf mehr Spielzeit.';

  @override
  String get recentlyPlayed => 'Kürzlich gespielt';

  @override
  String get recommended => 'Empfohlen';

  @override
  String get recommendedOnly => 'Nur empfohlen';

  @override
  String get reconnectAttempts => 'Wiederverbindungsversuche';

  @override
  String get reconnectNow => 'Jetzt wieder verbinden';

  @override
  String get reconnectionFailed => 'Die erneute Verbindung ist fehlgeschlagen';

  @override
  String get reconnectionSuccessful => 'Wiederverbindung erfolgreich';

  @override
  String get recorded => 'Aufgezeichnet';

  @override
  String get refreshAppleMusic => 'Aktualisieren Sie Apple Music';

  @override
  String get refreshDevices => 'Geräte aktualisieren';

  @override
  String get refreshDevices2 => 'Geräte aktualisieren';

  @override
  String get refreshMotionArt => 'Bewegungskunst aktualisieren';

  @override
  String get refreshOutputs => 'Ausgaben aktualisieren';

  @override
  String get refreshingAppleMusicData => 'Aktualisieren der Apple Music-Daten';

  @override
  String get registeredNotClaimed => 'Registriert, nicht beansprucht';

  @override
  String get reinitializingPlayback => 'Wiedergabe wird neu initialisiert…';

  @override
  String get release => 'Veröffentlichung';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeAll => 'Alles entfernen';

  @override
  String get removeAllWithBestPicks => 'Alles mit den besten Tipps entfernen?';

  @override
  String get removeCustomArt => 'Benutzerdefinierte Grafiken entfernen';

  @override
  String removeDuplicates2(Object toRemove) {
    return '$toRemove-Duplikate entfernen?';
  }

  @override
  String removeDuplicates3(Object toRemove) {
    return 'Entfernen Sie $toRemove-Duplikate';
  }

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get removeFromFavorites2 => 'Aus Favoriten entfernen';

  @override
  String get removeFromLibrary => 'Aus der Bibliothek entfernen';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get removeSelected => 'Ausgewählte entfernen';

  @override
  String get removeServer => 'Server entfernen?';

  @override
  String get removeServer2 => 'Server entfernen';

  @override
  String get removeTheDatabaseEntriesOrDelete =>
      'Entfernen Sie die Datenbankeinträge oder löschen Sie die Dateien von Ihrem Gerät. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get removeTheDatabaseEntryOrDelete =>
      'Entfernen Sie den Datenbankeintrag oder löschen Sie die Datei von Ihrem Gerät. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get removeTheseSongsFromYourLibrary =>
      'Entfernen Sie diese Songs aus Ihrer Bibliothek. Die Dateien auf Ihrem Gerät sind davon nicht betroffen.';

  @override
  String get removeThisSongFromYourLibrary =>
      'Entfernen Sie dieses Lied aus Ihrer Bibliothek. Die Datei auf Ihrem Gerät ist davon nicht betroffen.';

  @override
  String removedCustomAlbumArtFor(Object arg1) {
    return 'Benutzerdefiniertes Albumcover für „$arg1“ entfernt.';
  }

  @override
  String removedCustomAlbumArtFor2(Object arg1) {
    return 'Benutzerdefiniertes Albumcover für „$arg1“ entfernt.';
  }

  @override
  String removedDuplicatesKept(Object arg1, Object arg2) {
    return '$arg1-Duplikate entfernt – $arg2 beibehalten.';
  }

  @override
  String removedFromFavorites(Object arg1) {
    return '„$arg1“ aus den Favoriten entfernt';
  }

  @override
  String removedFromFavorites2(Object arg1) {
    return '$arg1 aus den Favoriten entfernt';
  }

  @override
  String get removedFromFavorites3 => 'Aus den Favoriten entfernt';

  @override
  String removedFromLibrary(Object arg1) {
    return '„$arg1“ aus der Bibliothek entfernt';
  }

  @override
  String removedSongsFromFavorites(Object arg1) {
    return '$arg1-Songs aus den Favoriten entfernt';
  }

  @override
  String removedSongsFromLibrary(Object arg1) {
    return '$arg1-Songs aus der Bibliothek entfernt';
  }

  @override
  String get removing => 'Entferne…';

  @override
  String get removingDuplicates => 'Duplikate werden entfernt…';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renamePreset => 'Voreinstellung umbenennen';

  @override
  String get reorderFilterAndShuffleFromThis =>
      'Von diesem Header aus neu anordnen, filtern und mischen.';

  @override
  String repeat(Object arg1) {
    return 'Wiederholen: $arg1';
  }

  @override
  String get repeatMode => 'Wiederholungsmodus';

  @override
  String get repeatRewind => 'Wiederholen Sie den Vorgang „Zurückspulen“.';

  @override
  String get replaceAlbumNameWithAVerified =>
      'Ersetzen Sie den Albumnamen durch eine verifizierte Bit-Perfect-Kapsel, wenn Sie Bit-Perfect streamen';

  @override
  String get replay => 'Erneut abspielen';

  @override
  String get replayCouldnTLoad => 'Wiederholung konnte nicht geladen werden.';

  @override
  String get replayStudio => 'Replay Studio';

  @override
  String get reportedOutputRate => 'Gemeldete Ausgaberate';

  @override
  String get requestedOutputRate => 'Angeforderte Ausgaberate';

  @override
  String get requiredToDetectDevicesCodecsAnd =>
      'Erforderlich, um Geräte, Codecs und Batteriestände zu erkennen';

  @override
  String get resampler => 'Resampler';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetArtwork => 'Bildmaterial zurücksetzen';

  @override
  String get resetArtworkDescription =>
      'Bildmaterial aus den Dateien dieses Albums erneut erkennen? Automatisch erkannte Cover werden durch aus den Dateien gelesene Grafiken ersetzt; Benutzerdefinierte Grafiken bleiben erhalten.';

  @override
  String resetArtworkFor(Object arg1) {
    return 'Bildmaterial für „$arg1“ zurücksetzen.';
  }

  @override
  String resetArtworkFor2(Object arg1) {
    return 'Bildmaterial für „$arg1“ zurücksetzen.';
  }

  @override
  String get resetCardDesign => 'Kartendesign zurücksetzen';

  @override
  String get resetDeclinedUsbDacs => 'Abgelehnte USB-DACs zurücksetzen';

  @override
  String get resetDynamics => 'Dynamik zurücksetzen';

  @override
  String get resetFx => 'FX zurücksetzen';

  @override
  String get resetMiniPlayerToDefaults =>
      'Setzen Sie den Mini-Player auf die Standardeinstellungen zurück';

  @override
  String get resetPreferences => 'Einstellungen zurücksetzen';

  @override
  String get resetTo0Db => 'Auf 0 dB zurücksetzen';

  @override
  String get resolution => 'Auflösung';

  @override
  String get resonance => 'Resonanz';

  @override
  String get restart => 'Neustart';

  @override
  String get restartRequired => 'Neustart erforderlich';

  @override
  String get restartTheAppToApplyPlayback =>
      'Starten Sie die App neu, um die Wiedergabeänderungen zu übernehmen.';

  @override
  String get restartYourDeviceToApplyOutput =>
      'Starten Sie Ihr Gerät neu, um die Änderungen im Ausgabeformat zu übernehmen.';

  @override
  String get restartingFlick => 'Neustart von Hadoo';

  @override
  String results(Object arg1) {
    return 'Ergebnisse ($arg1)';
  }

  @override
  String get resumeAFamiliarFavoriteOrShuffle =>
      'Nehmen Sie einen vertrauten Favoriten wieder auf oder mischen Sie einen der Mixe, die Sie beim Zuhören erstellt haben.';

  @override
  String get resumeOnReconnect => 'Bei erneuter Verbindung fortfahren';

  @override
  String get retakePhoto => 'Foto erneut aufnehmen';

  @override
  String get retroFuture => 'Retro-Zukunft';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get reviewBeforeYouClean =>
      'Überprüfen Sie es, bevor Sie mit der Reinigung beginnen';

  @override
  String get rightBottom => 'Rechts (unten)';

  @override
  String get rightBottomButton => 'Rechte (untere) Taste';

  @override
  String get rightTop => 'Rechts (oben)';

  @override
  String get rightTopButton => 'Rechte (obere) Taste';

  @override
  String get ripSource => 'Rip-Quelle';

  @override
  String get root => 'Wurzel';

  @override
  String get rotationSeek => 'Rotation suchen';

  @override
  String get roundedAlbumArtCardWithA =>
      'Abgerundete Albumcover-Karte mit unscharfem Albumcover-Hintergrund.';

  @override
  String get route => 'Route';

  @override
  String get routesBluetoothThroughTheHiRes =>
      'Leitet Bluetooth über die hochauflösende Rust-Engine weiter';

  @override
  String get routesBluetoothThroughTheRustEngine =>
      'Leitet Bluetooth über die Rust-Engine weiter';

  @override
  String get rustViaOboe => 'Rust über Oboe';

  @override
  String get rustViaOboeHighRes => 'Rust über Oboe (hochauflösend)';

  @override
  String s(Object arg1) {
    return '${arg1}s';
  }

  @override
  String sAgo(Object arg1) {
    return 'Vor ${arg1}s';
  }

  @override
  String get sambaWindowsShareTransportPending => 'Samba · Windows-Freigabe';

  @override
  String get sampleArtist => 'Beispielkünstler';

  @override
  String get samplePreview => 'Beispielvorschau';

  @override
  String get sampleRate => 'Abtastrate';

  @override
  String get sampleRate2 => 'Abtastrate';

  @override
  String get sampleRates => 'Beispielraten';

  @override
  String get sampleSongPreviewOnly => 'Beispielsong · Nur Vorschau';

  @override
  String get samples => 'Proben';

  @override
  String get save => 'Speichern';

  @override
  String get saveAsText => 'Als Text speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get saveConnect => 'Speichern und verbinden';

  @override
  String get saveCreatesAnLrcFileIf =>
      'Speichern erstellt eine `.lrc`-Datei. Wenn einige Zeilen noch nicht gestempelt sind, füllt Hadoo deren Zeiten automatisch auf, sodass die Datei verwendbar bleibt. Zeilen mit vollständig gestempelten Wörtern werden mit Karaoke-Timing pro Wort exportiert.';

  @override
  String get saveCurrentAsPreset => 'Aktuelles als Voreinstellung speichern';

  @override
  String get saveCustomizeReplay => 'Wiedergabe speichern/anpassen';

  @override
  String get saveInFlick => 'Speichern Sie in Hadoo';

  @override
  String get saveLogs => 'Protokolle speichern';

  @override
  String get saveLrcFile => 'Speichern Sie die LRC-Datei';

  @override
  String get saveLrcFile2 => 'LRC-Datei speichern';

  @override
  String get saveLyrics => 'Liedtext speichern';

  @override
  String get savePng => 'PNG speichern';

  @override
  String get savePreset => 'Voreinstellung speichern';

  @override
  String get saveTheCurrentEqAsJson =>
      'Speichern Sie den aktuellen EQ als JSON oder TXT';

  @override
  String get saved => 'Gespeichert';

  @override
  String get savedAgain => 'Wieder gespeichert ·';

  @override
  String get savedAndVerified => 'Gespeichert und verifiziert';

  @override
  String savedCollections(Object playlistCount) {
    return '$playlistCount gespeicherte Sammlungen';
  }

  @override
  String get savedLyricsAndLinkedThemTo =>
      'Liedtext gespeichert und mit diesem Lied verknüpft.';

  @override
  String get savedLyricsBesideTheSongAs =>
      'Liedtext neben dem Lied als `.lrc`-Datei gespeichert.';

  @override
  String get savedLyricsToTheChosenLocation =>
      'Songtexte am gewählten Ort gespeichert.';

  @override
  String get savedPlaylistsAndQuickJumpsInto =>
      'Gespeicherte Wiedergabelisten und schnelle Sprünge in Ihre Bibliotheksorganisation.';

  @override
  String get savedToGallery => 'In der Galerie gespeichert';

  @override
  String savedToNNNshareIt(Object path) {
    return 'Gespeichert unter:\n$path\n\nJetzt teilen?';
  }

  @override
  String savedToYourGallery(Object arg1) {
    return '$arg1 in Ihrer Galerie gespeichert';
  }

  @override
  String get savedVerificationPending => 'Gespeichert (Bestätigung ausstehend)';

  @override
  String get saving => 'Speichern…';

  @override
  String get scaleTheAlbumArtCard => 'Skalieren Sie die Albumcover-Karte';

  @override
  String get scaleTheFullViewAlbumArt =>
      'Skalieren Sie die Albumcover-Karte in Vollansicht';

  @override
  String get scalesWithWidgetSizeAutomatically =>
      'Skaliert automatisch mit der Widget-Größe';

  @override
  String get scanAgain => 'Noch einmal scannen';

  @override
  String get scanForDevices => 'Nach Geräten suchen';

  @override
  String get scanProgress => 'Scanfortschritt';

  @override
  String get scanningForDuplicates => 'Nach Duplikaten suchen…';

  @override
  String get scanningYourLibrary => 'Scannen Sie Ihre Bibliothek…';

  @override
  String get scroll => 'Scrollen';

  @override
  String get scrollForMore => 'Für mehr scrollen';

  @override
  String get scrollingPausesWhenReducedMotionIs =>
      'Das Scrollen wird angehalten, wenn die reduzierte Bewegung aktiviert ist';

  @override
  String get search => 'Suchen';

  @override
  String get searchAcrossSongsArtistsAndAlbums =>
      'Durchsuchen Sie sofort Songs, Künstler und Alben.';

  @override
  String get searchAgain => 'Erneut suchen';

  @override
  String get searchArtistTitle => 'Künstler + Titel suchen...';

  @override
  String get searchArtists => 'Künstler suchen…';

  @override
  String get searchFailed => 'Die Suche ist fehlgeschlagen';

  @override
  String searchFailed2(Object e) {
    return 'Suche fehlgeschlagen: $e';
  }

  @override
  String get searchHeadphones => 'Kopfhörer suchen…';

  @override
  String searchModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Modelle',
      one: '$count-Modell',
    );
    return 'Suchen $_temp0…';
  }

  @override
  String get searchOnline => 'Online suchen';

  @override
  String get searchOnline2 => 'Online suchen';

  @override
  String get searchOnlineCreateYourOwnSynced =>
      'Suchen Sie online, erstellen Sie Ihre eigenen synchronisierten Liedtexte oder importieren Sie eine vorhandene Datei.';

  @override
  String get searchOnlineLyrics => 'Suchen Sie online nach Songtexten';

  @override
  String get searchSongsArtists => 'Suchen Sie nach Liedern, Künstlern...';

  @override
  String get searchSongsArtistsAlbums =>
      'Suchen Sie nach Liedern, Künstlern, Alben ...';

  @override
  String get searchTheManual => 'Suche im Handbuch...';

  @override
  String get searchYourLibrary => 'Mediathek durchsuchen';

  @override
  String get searching => 'Suche…';

  @override
  String get searchingOnline => 'Online-Suche';

  @override
  String get searchingTheLocalNetwork => 'Suche im lokalen Netzwerk…';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String seeAll2(Object count) {
    return 'Alle anzeigen $count';
  }

  @override
  String get select => 'Auswählen';

  @override
  String get selectALineAndEdit =>
      '1. Wählen Sie eine Zeile aus und bearbeiten Sie ihren Zeitstempel direkt oder verwenden Sie „Aktuelle Zeit verwenden“.\n2. Ziehen Sie in der Word-Timeline eine Grenze, um das Segment davor zu dehnen oder zu verkleinern – die Bearbeitung erfolgt bei 10 ms.\n3. Tippen Sie im Informationsfenster auf Buchstaben, um ein Wort in separate Silben zu unterteilen (langsames, dann schnelles Tempo), und ziehen Sie dann deren Grenzen.\n4. Ziehen Sie die letzte Grenze (oder verwenden Sie Länge ±), um die nächste Linie neu zu planen. Verwenden Sie die automatische Ausfüllung, um Wörter mit gleichmäßigem Abstand zu setzen.\n5. Verwenden Sie die Umschaltsteuerung, um alle gestempelten Liedtexte zusammen zu verschieben.\n6. Speichern Sie, um die endgültige `.lrc`-Datei zu generieren.';

  @override
  String get selectARelease => 'Wählen Sie eine Veröffentlichung aus';

  @override
  String get selectAll => 'Wählen Sie „Alle“ aus';

  @override
  String get selectAll2 => 'Alles auswählen';

  @override
  String get selectDevice => 'Wählen Sie Gerät aus';

  @override
  String selected(Object count) {
    return '$count ausgewählt';
  }

  @override
  String selectedOfSong(Object selected, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$selected ausgewählt aus $_temp0';
  }

  @override
  String get sep => 'Sept';

  @override
  String get separateFromNavBar => 'Getrennt von der Navigationsleiste';

  @override
  String get separateTheMiniPlayerToCustomize =>
      'Trennen Sie den Mini-Player, um Breite und Abstand anzupassen. Ihre benutzerdefinierten Werte werden beim Beitritt gespeichert.';

  @override
  String get serialNumber => 'Seriennummer';

  @override
  String serverPlaylistSyncFailed(Object e) {
    return 'Synchronisierung der Server-Wiedergabeliste fehlgeschlagen: $e';
  }

  @override
  String get serverUrl => 'Server-URL';

  @override
  String get session => 'Sitzung';

  @override
  String get setAlbumArt => 'Legen Sie das Albumcover fest';

  @override
  String get setToNow => 'Auf „Jetzt“ einstellen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shadow => 'Schatten';

  @override
  String get shadowJazz => 'Schattenjazz';

  @override
  String get share => 'Teilen';

  @override
  String shareFailed(Object e) {
    return 'Freigabe fehlgeschlagen: $e';
  }

  @override
  String get sharedSecret => 'Geteiltes Geheimnis';

  @override
  String get shiftMetadataTextUpOrDown =>
      'Metadatentext nach oben oder unten verschieben';

  @override
  String get shiftOnlyTheAlbumArtUp =>
      'Verschieben Sie nur das Albumcover nach oben oder unten';

  @override
  String get shiftOnlyTheSongDetailsUp =>
      'Verschieben Sie nur die Songdetails nach oben oder unten';

  @override
  String get showAThinPlaybackProgressLine =>
      'Zeigt eine dünne Fortschrittslinie für die Wiedergabe an';

  @override
  String get showAlbum => 'Album anzeigen';

  @override
  String get showAlbum2 => 'Album anzeigen';

  @override
  String get showAlbumArtwork => 'Albumcover anzeigen.';

  @override
  String get showAlbumArtworkOnTheMini =>
      'Albumcover auf dem Miniplayer anzeigen';

  @override
  String get showArtist => 'Künstler anzeigen';

  @override
  String get showArtist2 => 'Künstler anzeigen';

  @override
  String get showArtistBelowSongTitle => 'Interpret unter Songtitel anzeigen';

  @override
  String get showFileInfo => 'Dateiinformationen anzeigen';

  @override
  String get showFileInfo2 => 'Dateiinformationen anzeigen';

  @override
  String get showFrame => 'Rahmen anzeigen';

  @override
  String get showFrame2 => 'Rahmen anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get showLyrics => 'Songtext anzeigen';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showOtherArtistsOnAlbumPages =>
      'Andere Künstler auf Albumseiten anzeigen';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get showRelatedAlbumsOnAlbumPages =>
      'Verwandte Alben auf Albumseiten anzeigen';

  @override
  String get showTheArtistBelowTheSong =>
      'Zeigen Sie den Interpreten unter dem Songtitel an';

  @override
  String get showTheAudioVisualizerOffSaves =>
      'Audio-Visualizer anzeigen (aus spart Batterie)';

  @override
  String get showTheGlassFrameAroundAlbum =>
      'Zeigen Sie den Glasrahmen um das Albumcover herum';

  @override
  String get showTheMiniPlayerAsIts =>
      'Zeigen Sie den Miniplayer als eigene Leiste über den Schaltflächen an';

  @override
  String get showTheNumberOverBlurredArt =>
      'Zeigen Sie die Zahl über unscharfer Grafik an.';

  @override
  String get showTheTrackNumber => 'Zeigt die Titelnummer an.';

  @override
  String get showTitle => 'Titel anzeigen';

  @override
  String get showTitle2 => 'Titel anzeigen';

  @override
  String get showVerboseAudioDiagnosticsAndEngine =>
      'Zeigen Sie ausführliche Audiodiagnosen und Engine-/Sitzungs-Trace-Protokolle an.';

  @override
  String get showVisualizer => 'Visualizer anzeigen';

  @override
  String showingAllAlbums(Object totalCount) {
    return 'Alle $totalCount-Alben werden angezeigt';
  }

  @override
  String showingOfAlbums(Object visibleCount, Object totalCount) {
    return 'Zeigt $visibleCount von $totalCount-Alben';
  }

  @override
  String get showingYourLastLoadedReplay =>
      'Zeigt Ihr zuletzt geladenes Replay.';

  @override
  String get shownWhenThereIsRoomBeside =>
      'Wird angezeigt, wenn neben den Bedienelementen Platz ist';

  @override
  String get showsWhatSPlayingTapTo =>
      'Zeigt, was gerade abgespielt wird. Tippen Sie hier, um den vollständigen Player zu öffnen.';

  @override
  String get shuffle => 'Zufallswiedergabe';

  @override
  String shuffle2(Object arg1) {
    return 'Mischen: $arg1';
  }

  @override
  String get shuffleFavorites => 'Favoriten mischen';

  @override
  String get shuffleMode => 'Zufallsmodus';

  @override
  String get shuffleSongsAndJumpBetweenCategories =>
      'Mischen Sie Songs und wechseln Sie zwischen Kategorien';

  @override
  String get shuffleSongsInCurrentList =>
      'Lieder in der aktuellen Liste mischen';

  @override
  String get signInFailedRetry => 'Anmeldung fehlgeschlagen – erneut versuchen';

  @override
  String get signInWithTidal => 'Melden Sie sich mit Tidal an';

  @override
  String get signInWithYourAccountHifi =>
      'Melden Sie sich mit Ihrem Konto an · HiFi verlustfrei';

  @override
  String get signInWithYourOwnTidal =>
      'Melden Sie sich mit Ihrem eigenen Tidal-Konto an. HiFi verlustfrei (FLAC/ALAC) spielt über die bit-perfekte Engine; HiRes/MQA und Atmos werden von Tidal gesteuert und zeigen statt der Wiedergabe einen Fehler an.';

  @override
  String get signal => 'Signal';

  @override
  String get signalAccurateUnverified => 'AccurateRip nicht verifiziert';

  @override
  String get signalAccurateVerified => 'AccurateRip im Protokoll überprüft';

  @override
  String get signalAltSetting => 'Alt-Einstellung';

  @override
  String get signalBufferCapacity => 'Pufferkapazität';

  @override
  String get signalBufferFill => 'Pufferfüllung';

  @override
  String get signalBufferOccupancy => 'Pufferbelegung bei geöffnetem Zustand';

  @override
  String get signalBufferTarget => 'Pufferziel';

  @override
  String get signalCopyCrc => 'CRC kopieren';

  @override
  String get signalCrcCannotCompare => 'Kann nicht verglichen werden';

  @override
  String get signalCrcComparison => 'CRC-Vergleich';

  @override
  String get signalCrcMatch => 'Übereinstimmung';

  @override
  String get signalCrcMismatch => 'Nichtübereinstimmung';

  @override
  String get signalDriftFromTarget => 'Vom Ziel abdriften';

  @override
  String get signalDsdBitRate => 'DSD-Bitrate';

  @override
  String get signalFileFormat => 'Dateiformat';

  @override
  String get signalFramesPerPacket => 'Frames/Paket';

  @override
  String get signalMaxPacket => 'Maximales Paket';

  @override
  String get signalNoRipDescription =>
      'Für diesen Titel wurden keine Ripping- oder Verifizierungsinformationen gefunden.';

  @override
  String get signalNotReported => 'Nicht gemeldet';

  @override
  String get signalNotVerified => 'Nicht bestätigt';

  @override
  String get signalRecordingUnavailable => 'Rip-Verlauf nicht verfügbar';

  @override
  String get signalRipDescription =>
      'Informationen aus dem Rip-Protokoll, keine Phase des aktuellen Wiedergabepfads.';

  @override
  String get signalRipProvenance => 'Rip-Herkunft';

  @override
  String get signalRipper => 'Ripper';

  @override
  String get signalServiceInterval => 'Serviceintervall';

  @override
  String get signalSnapshot => 'Überblick';

  @override
  String get signalSnapshotAtOpen => 'Schnappschuss beim Öffnen';

  @override
  String get signalSourceDescription =>
      'Eigenschaften der Quelldatei, nicht der an das Gerät gesendeten Ausgabe.';

  @override
  String get signalSourceDetails => 'Details zum Quellformat';

  @override
  String get signalSubslot => 'Subslot';

  @override
  String get signalSyncType => 'Synchronisierungstyp';

  @override
  String get signalTarget => 'Ziel';

  @override
  String get signalTestCrc => 'CRC testen';

  @override
  String get signalTransportFormat => 'Transport';

  @override
  String get signalUnderruns => 'Unterschreitungen';

  @override
  String get signalUsageType => 'Nutzungsart';

  @override
  String get signalUsbDescription =>
      'Transportwerte verfügbar, als dieses Blatt geöffnet wurde. Dies ist keine Live-Paketverfolgung.';

  @override
  String get signalUsbMissingDescription =>
      'URB-Details werden nur für den direkten USB-Pfad gemeldet. Es wird keine Übertragungsaktivität abgeleitet.';

  @override
  String get signalUsbTransport => 'USB-Transport';

  @override
  String get signalUsbUnavailable => 'USB-Transportdetails nicht verfügbar';

  @override
  String get signalVerificationMissing => 'Verifizierung nicht gemeldet';

  @override
  String get signalVerifiedInLog => 'Im Protokoll überprüft';

  @override
  String get signedIn => 'Angemeldet';

  @override
  String get silkySmoothBZierCurvesFluid =>
      'Seidig glatte Bézier-Kurven – fließend und organisch';

  @override
  String get similarArtists => 'Ähnliche Künstler';

  @override
  String get simple => 'Einfach';

  @override
  String get simpleMode => 'Einfacher Modus';

  @override
  String get single => 'Single';

  @override
  String get size => 'Größe';

  @override
  String get skip => 'Überspringen';

  @override
  String skippedUnmatchedEntr(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nicht übereinstimmende Einträge',
      one: '$count nicht übereinstimmender Eintrag',
    );
    return ' Übersprungen $_temp0.';
  }

  @override
  String get sleepTimer => 'Sleep-Timer';

  @override
  String get sleepTimer2 => 'Sleep-Timer';

  @override
  String get sleeves => 'Ärmel';

  @override
  String get slope => 'Steigung';

  @override
  String get smbSharesCanBeAddedNow =>
      'SMB2/3-Freigaben verbinden sich über den integrierten Client. Geben Sie die Freigabe-URL (smb://host/share) ein und melden Sie sich an, wenn der Server danach fragt.';

  @override
  String get smooth => 'Glatt';

  @override
  String get smoothsPeaksAndRaisesBodyBefore =>
      'Glättet Spitzen und hebt den Körper an, bevor der Begrenzer Transienten auffängt.';

  @override
  String get snappy => 'Bissig';

  @override
  String get softwareAppControlled => 'Software (App-gesteuert)';

  @override
  String get solid => 'Solide';

  @override
  String get someOnlineFeaturesMayNotWork =>
      '  · Einige Online-Funktionen funktionieren möglicherweise nicht';

  @override
  String get someWordsAreStillUntimedFinish =>
      'Einige Wörter sind noch ohne Zeitangabe. Beenden Sie die Aufnahme im Word-Sync-Modus.';

  @override
  String get somethingWentWrong => 'Etwas ist schief gelaufen';

  @override
  String song2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$_temp0';
  }

  @override
  String song3(int count, Object server) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$_temp0 · $server';
  }

  @override
  String get songActions => 'Song-Aktionen';

  @override
  String get songArtist => 'Liedkünstler';

  @override
  String get songCount => 'Liedanzahl';

  @override
  String get songGestures => 'Liedgesten';

  @override
  String get songMetadata => 'Song-Metadaten';

  @override
  String get songTitle => 'Songtitel';

  @override
  String songUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lieder',
      one: 'Lied',
    );
    return '$_temp0';
  }

  @override
  String songs(Object arg1, Object arg2) {
    return '$arg1 • $arg2-Songs';
  }

  @override
  String songs12(Object arg1) {
    return '$arg1-Songs';
  }

  @override
  String songs13(Object count) {
    return '$count Titel';
  }

  @override
  String get songs14 => 'Titel';

  @override
  String songs15(Object arg1) {
    return '$arg1-Songs';
  }

  @override
  String songs2(Object songCount) {
    return '$songCount-Songs';
  }

  @override
  String songs3(Object arg1) {
    return '$arg1-Songs';
  }

  @override
  String songs4(Object _totalSongs) {
    return '$_totalSongs-Songs';
  }

  @override
  String songs5(Object arg1) {
    return '$arg1-Songs';
  }

  @override
  String songs9(Object arg1) {
    return '$arg1-Songs';
  }

  @override
  String songsAlbums(Object arg1, Object uniqueAlbums) {
    return '$arg1-Songs • $uniqueAlbums-Alben';
  }

  @override
  String songsAlbums2(Object arg1, Object albumCount) {
    return '$arg1-Songs · $albumCount-Alben';
  }

  @override
  String get songsCategories => 'Lieder und Kategorien';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs',
      one: '$count Lied',
    );
    return '$_temp0';
  }

  @override
  String songsFound(Object arg1) {
    return '$arg1 Songs gefunden';
  }

  @override
  String songsIn(int songs, int folders) {
    String _temp0 = intl.Intl.pluralLogic(
      songs,
      locale: localeName,
      other: '$songs-Songs',
      one: '$songs Lied',
    );
    String _temp1 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: '$folders-Ordner',
      one: '$folders-Ordner',
    );
    return '$_temp0 in $_temp1';
  }

  @override
  String songsInRotation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Songs in Ihrer Rotation',
      one: '$count-Song in Ihrer Rotation',
    );
    return '$_temp0';
  }

  @override
  String get songsTab => 'Registerkarte „Lieder“.';

  @override
  String songsU2022Albums(Object arg1, Object uniqueAlbums) {
    return '$arg1-Songs • $uniqueAlbums-Alben';
  }

  @override
  String get songsYouPlayWillAppearHere =>
      'Die von Ihnen gespielten Songs werden hier angezeigt';

  @override
  String get songsYouScanIntoYourLibrary =>
      'Songs, die Sie in Ihre Bibliothek scannen, werden hier angezeigt';

  @override
  String get sortBy => 'SORTIEREN NACH';

  @override
  String get sortFilter => 'Sortieren und filtern';

  @override
  String get sortSongs => 'Lieder sortieren';

  @override
  String get source => 'Quelle';

  @override
  String get sourceRate => 'Quellenrate';

  @override
  String get spaceBetweenTheTwoBars => 'Abstand zwischen den beiden Balken';

  @override
  String get spaceOdyssey => 'Weltraum-Odyssee';

  @override
  String get spatialTime => 'Räumlich und zeitlich';

  @override
  String get speedUp => 'Beschleunigen Sie';

  @override
  String get springPhysicsEnergeticAndReactive =>
      'Frühlingsphysik – energisch und reaktiv';

  @override
  String get stampNext => 'Stempel & Weiter';

  @override
  String get stampNow => 'Jetzt stempeln';

  @override
  String get stampThisLineFirstToEdit =>
      'Stempeln Sie diese Zeile zuerst, um die Wortzeitleiste zu bearbeiten.';

  @override
  String get standard => 'Standard';

  @override
  String get standardBluetoothRoutingViaAndroid =>
      'Standard-Bluetooth-Routing über Android';

  @override
  String get standardEngine => 'Standardmotor';

  @override
  String get starlightSerenade => 'Sternenlicht-Serenade';

  @override
  String get start => 'Starten';

  @override
  String get startAtNow => 'Beginnen Sie jetzt';

  @override
  String get startBuildingYourHome => 'Beginnen Sie mit dem Bau Ihres Hauses';

  @override
  String get startPlayingToPopulateThisSpace =>
      'Beginnen Sie zu spielen, um diesen Raum zu füllen';

  @override
  String get startStreaming => 'Starten Sie das Streaming';

  @override
  String get startedPresetDownload => 'Preset-Download gestartet.';

  @override
  String get state => 'Staat';

  @override
  String get status => 'Status';

  @override
  String get stereo => 'Stereo';

  @override
  String get stop => 'Stoppen';

  @override
  String get stopCasting => 'Stoppen Sie das Casting';

  @override
  String get stopStreaming => 'Stoppen Sie das Streaming';

  @override
  String get stopUsbOnQuit => 'Stoppen Sie USB beim Beenden';

  @override
  String stoppingIn(Object arg1) {
    return 'Anhalten in $arg1';
  }

  @override
  String get storeOn => 'Speichern Sie auf';

  @override
  String get storedAsASaltedHashNever =>
      'Wird als gesalzener Hash gespeichert, niemals im Klartext';

  @override
  String get storedEncodedPlaybackUnavailableInThis =>
      'Base64-codiert gespeichert – für die NTLM-Anmeldung erforderlich';

  @override
  String get stormChasers => 'Sturmjäger';

  @override
  String get strategy => 'Strategie';

  @override
  String get stream => 'Stream';

  @override
  String get streamConfigurationNotAvailable =>
      'Stream-Konfiguration nicht verfügbar';

  @override
  String get streamStable => 'Stream stabil';

  @override
  String get streaming => 'Streaming';

  @override
  String get streamingFromQueue => 'Streaming aus der Warteschlange';

  @override
  String get strong => 'Stark';

  @override
  String get studioGradeOutputForExternalDacs =>
      'Ausgang in Studioqualität für externe DACs und Kopfhörerverstärker. Umgeht die Audioverarbeitung von Android für reinen Klang.';

  @override
  String get sub => 'Sub';

  @override
  String subfolderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Unterordner',
      one: 'Unterordner $count',
    );
    return '$_temp0';
  }

  @override
  String get subsonic => 'Unterschall';

  @override
  String get subtle => 'Subtil';

  @override
  String get supportFlick => 'Unterstützt Flick';

  @override
  String get supportFlickOnKoFi => 'Unterstützen Sie Flick auf Ko-Fi';

  @override
  String get surfaceShading => 'Oberflächenbeschattung';

  @override
  String get swipeHorizontallyToFineTuneEach =>
      'Wischen Sie horizontal, um jedes Mittelband fein abzustimmen.';

  @override
  String get swipeLeftRightToSkipTracks =>
      'Wischen Sie nach links/rechts, um Titel zu überspringen';

  @override
  String get swipeToShowOrHideThe =>
      'Wischen Sie, um den Visualizer anzuzeigen oder auszublenden';

  @override
  String get switchSongs => 'Lieder wechseln';

  @override
  String get switchToTheExclusiveUsbPath =>
      'Wechseln Sie automatisch zum exklusiven USB-Pfad, wenn ein DAC angeschlossen ist. Abgelehnte DACs werden in Erinnerung gerufen.';

  @override
  String get switchedBackToTheAutomaticLyrics =>
      'Zurück zur automatischen Liedtextquelle gewechselt.';

  @override
  String get syllablesTapALetterToSplit =>
      'Silben – tippen Sie auf einen Buchstaben, um ihn zu teilen oder zusammenzuführen:';

  @override
  String get symmetricalBarsMirroredFromTheCenter =>
      'Symmetrische Balken, gespiegelt von der Mitte';

  @override
  String syncFailed(Object e) {
    return 'Synchronisierung fehlgeschlagen: $e';
  }

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncServerPlaylists => 'Server-Wiedergabelisten synchronisieren';

  @override
  String get synced => 'Synchronisiert';

  @override
  String synced2(Object arg1) {
    return 'Synchronisiert $arg1';
  }

  @override
  String get syncedLrc => 'Synchronisiertes LRC';

  @override
  String syncedPlaylistFromServers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-Wiedergabelisten',
      one: '$count-Wiedergabeliste',
    );
    return 'Synchronisiert $_temp0 von Servern';
  }

  @override
  String get syncing => 'Synchronisierung…';

  @override
  String get synthwaveCity => 'Synthwave City';

  @override
  String get systemAndroidMixer => 'System (Android-Mixer)';

  @override
  String get tagsWereWrittenButCouldNot =>
      'Tags wurden geschrieben, konnten aber durch erneutes Lesen der Datei nicht bestätigt werden. Durch einen erneuten Scan der Bibliothek werden eventuelle Unterschiede ausgeglichen.';

  @override
  String tap(Object label) {
    return 'Tippen Sie auf: „$label“';
  }

  @override
  String get tapABandToExpandDrag =>
      'Tippen Sie auf ein Band, um es zu erweitern. Ziehen Sie zum Anpassen einen Knopf. Tippen Sie auf einen Wert, um ihn direkt einzugeben.';

  @override
  String get tapAllOrEnableAChip =>
      'Tippen Sie auf „Alle“ oder aktivieren Sie einen Chip, um Ergebnisse anzuzeigen';

  @override
  String get tapChipsToFilterCategories =>
      'Tippen Sie auf Chips, um Kategorien zu filtern';

  @override
  String get tapEditTextTopRight =>
      '1. Tippen Sie auf „Text bearbeiten“ (oben rechts) und fügen Sie den Liedtext ein – eine Zeile pro Zeile.\n2. Spielen Sie das Lied.\n3. Wählen Sie die aktuelle Zeile in der Zeilenliste aus.\n4. Tippen Sie auf „Stempeln und weiter“, wenn Sie diese Zeile hören.\n5. Speichern Sie, wenn Sie fertig sind.';

  @override
  String get tapIconsToSwitchTabsLong =>
      'Tippen Sie auf die Symbole, um zwischen den Tabs zu wechseln. Lange drücken, um die Leiste anzupassen.';

  @override
  String get tapTheHeartIconOnAny =>
      'Tippen Sie auf das Herzsymbol eines beliebigen Songs\n, um ihn zu Ihren Favoriten hinzuzufügen';

  @override
  String get tapTheMiniPlayerForWaveform =>
      'Tippen Sie auf den Mini-Player, um Wellenform-Suchleiste, EQ, Liedtexte und Visualizer anzuzeigen.';

  @override
  String get tapToInspect12602280Png =>
      'Zum Ansehen antippen · 1260 × 2280 PNG';

  @override
  String get tapToPlayLongPressFor =>
      'Zum Abspielen tippen, für Optionen lange drücken (Warteschlange, Nächstes abspielen, Info).';

  @override
  String get tapToPreview => 'Tippen Sie auf, um eine Vorschau anzuzeigen';

  @override
  String targetMs(Object arg1) {
    return 'Ziel $arg1 ms';
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
  String get testConnection => 'Testverbindung';

  @override
  String get textGestures => 'Text und Gesten';

  @override
  String get textPlacement => 'Textplatzierung';

  @override
  String get textPlacement2 => 'Textplatzierung';

  @override
  String get textSize => 'Textgröße';

  @override
  String get textSize2 => 'Textgröße';

  @override
  String get thatSTheTour => 'Das ist die Tour!';

  @override
  String get theAudioEngineDeterminesHowYour =>
      'Die Audio-Engine bestimmt, wie Ihre Musik wiedergegeben wird. Jede Option gleicht Zuverlässigkeit, Qualität und Kompatibilität unterschiedlich aus.';

  @override
  String get theIsochronousUsbEngineWillBe =>
      'Die isochrone USB-Engine wird gestoppt, wenn die App beendet wird.';

  @override
  String get theIsochronousUsbEngineWillStay =>
      'Die isochrone USB-Engine bleibt aktiv, wenn die App beendet wird.';

  @override
  String get theNamesShowingUpAgainAnd =>
      'Die Namen, die in Ihrer letzten Warteschlange immer wieder auftauchen.';

  @override
  String get thePosterIsNotReadyYet =>
      'Das Poster ist noch nicht fertig. Versuchen Sie erneut zu speichern.';

  @override
  String get theTracksDominatingYourWeeklyAnd =>
      'Die Titel, die Ihre wöchentliche und monatliche Zusammenfassung dominieren.';

  @override
  String get thisAppIsBuiltByA =>
      'Diese App wurde von einem Einzelentwickler ohne Budget erstellt. Wenn Sie High-Fidelity-Audio lieben, sollten Sie darüber nachdenken, dessen Entwicklung auf Ko-fi zu unterstützen.';

  @override
  String get thisDevice => 'Dieses Gerät';

  @override
  String get thisFolderAppearsToBeEmpty => 'Dieser Ordner scheint leer zu sein';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get thisMonthSRecap => 'Die Zusammenfassung dieses Monats';

  @override
  String thisRemovesAllEntriesFromMemory(Object arg1) {
    return 'Dadurch werden alle $arg1-Einträge aus dem Speicher entfernt.';
  }

  @override
  String get thisSlowsPlaybackTo432440 =>
      'Dadurch wird die Wiedergabe auf 432/440 verlangsamt (ca. 1,8 % niedrigere Tonhöhe und Tempo) und das bitperfekte Passthrough deaktiviert. Die Musik klingt etwas leiser. Aktivieren Sie dies nur, wenn Sie absichtlich eine A=432-Abstimmung wünschen.';

  @override
  String get thisSongHasNoFilePath =>
      'Dieses Lied hat keinen Dateipfad und kann nicht bearbeitet werden.';

  @override
  String get thisSongIsMissingAlbumMetadata =>
      'Für diesen Song fehlen Album-Metadaten, daher ist der Online-Abgleich begrenzt.';

  @override
  String get thisSongOnly => 'Nur dieses Lied';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisWeekSRecap => 'Die Zusammenfassung dieser Woche';

  @override
  String get thisYearSRecap => 'Die diesjährige Zusammenfassung';

  @override
  String get threshold => 'Schwelle';

  @override
  String get thunderRoad => 'Donnerstraße';

  @override
  String get tidal => 'Tidal';

  @override
  String get timeShift => 'Zeitverschiebung';

  @override
  String get timestamp => 'Zeitstempel';

  @override
  String get tips => 'Tipps';

  @override
  String get title => 'Titel';

  @override
  String get toRemove => 'Zum Entfernen';

  @override
  String get today => 'Heute';

  @override
  String get todaySRecap => 'Die heutige Zusammenfassung';

  @override
  String get toneControls => 'Klangregler';

  @override
  String get tools => 'Werkzeuge';

  @override
  String get top => 'Oben';

  @override
  String get topAlbum => 'Top-Album';

  @override
  String get topArtist => 'Top-Künstler';

  @override
  String get topArtists => 'Top-Künstler';

  @override
  String get topSongs => 'Top-Songs';

  @override
  String get topSongs2 => 'Top-Titel';

  @override
  String get track => 'Titel';

  @override
  String track2(Object arg1) {
    return 'Spur $arg1';
  }

  @override
  String get track3 => 'Tracknummer';

  @override
  String get trackBitDepth => 'Verfolgen Sie die Bittiefe';

  @override
  String get trackChannels => 'Verfolgen Sie Kanäle';

  @override
  String get trackCount => 'Trackanzahl';

  @override
  String get trackDsdRate => 'Verfolgen Sie die DSD-Rate';

  @override
  String get trackNumber => 'Titelnummer';

  @override
  String get trackSampleRate => 'Abtastrate verfolgen';

  @override
  String get trackTime => 'Verfolgen Sie die Zeit';

  @override
  String get trackTimeSumsTheFullDuration =>
      'Die Track-Zeit summiert die gesamte Dauer der protokollierten Spiele.';

  @override
  String tracks(Object _totalTracks) {
    return '$_totalTracks-Tracks';
  }

  @override
  String tracks2(Object arg1) {
    return '$arg1-Tracks';
  }

  @override
  String tracks3(Object arg1) {
    return '$arg1-Tracks';
  }

  @override
  String tracks4(Object arg1) {
    return '$arg1-Tracks';
  }

  @override
  String tracks5(Object arg1, Object arg2) {
    return '$arg1 · $arg2-Gleise';
  }

  @override
  String tracks6(Object arg1) {
    return '$arg1-Tracks';
  }

  @override
  String tracks7(Object trackCount, Object arg1) {
    return '$trackCount-Spuren • $arg1';
  }

  @override
  String tracks8(Object arg1) {
    return '$arg1-Tracks';
  }

  @override
  String tracksLikedSongsPlaylists(
    Object songCount,
    Object favoriteCount,
    Object playlistCount,
  ) {
    return '$songCount-Titel, $favoriteCount-Likes, $playlistCount-Wiedergabelisten';
  }

  @override
  String tracksReadyToRevisit(Object favoritesCount) {
    return '$favoritesCount-Tracks bereit für einen erneuten Besuch';
  }

  @override
  String get tracksThatFitTheQuieterSide =>
      'Titel, die zur ruhigeren Seite Ihrer Hörgewohnheiten passen.';

  @override
  String get transparent => 'Transparent';

  @override
  String get treble => 'Höhen';

  @override
  String get trueRandomMayRepeatBeforeList =>
      'Echter Zufall (kann vor Ende der Liste wiederholt werden)';

  @override
  String get truncate => 'Abschneiden';

  @override
  String get tryAdjustingYourSearchQuery =>
      'Versuchen Sie, Ihre Suchanfrage anzupassen';

  @override
  String get tryAgain => 'Versuchen Sie es erneut';

  @override
  String get tryAnotherKeywordOrEnableMore =>
      'Versuchen Sie es mit einem anderen Schlüsselwort oder aktivieren Sie weitere Kategorien';

  @override
  String get tryOriginalSearch => 'Versuchen Sie es mit der Originalsuche';

  @override
  String get tryPickingALocalImageIf =>
      'Versuchen Sie, ein lokales Image auszuwählen, wenn die Release-Metadaten ungewöhnlich sind.';

  @override
  String get typeABrandAndModelTo =>
      'Geben Sie eine Marke und ein Modell ein, um online zu suchen.';

  @override
  String get u162ByteSubslotsLlRr => 'U16 – 2-Byte-Subslots, LL|RR';

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
    return ' • $arg1-Bit';
  }

  @override
  String get u324ByteSubslotsLlllRrrr =>
      'U32 – 4-Byte-Subslots, LLLL|RRRR (Legacy)';

  @override
  String get u8ByteInterleavedLrlr => 'U8 – Byte-interleaved LRLR';

  @override
  String get u8ByteInterleavedRecommendedDefault =>
      'U8 – Byte-interleaved, empfohlener Standard';

  @override
  String get uac2IsNotAvailableOnThis =>
      'UAC2 ist auf dieser Plattform nicht verfügbar';

  @override
  String get uac2NotAvailableOnThisPlatform =>
      'UAC2 ist auf dieser Plattform nicht verfügbar';

  @override
  String get uac2Preferences => 'UAC2-Einstellungen';

  @override
  String get uac2PreferencesResetSuccessfully =>
      'UAC2-Einstellungen wurden erfolgreich zurückgesetzt';

  @override
  String get unableToCheckForUpdatesRight =>
      'Derzeit kann nicht nach Updates gesucht werden.';

  @override
  String unavailable(Object featureName) {
    return '$featureName Nicht verfügbar';
  }

  @override
  String get unavailable2 => 'Nicht verfügbar';

  @override
  String underruns(Object arg1) {
    return '$arg1 unterläuft';
  }

  @override
  String get undo => 'Rückgängig machen';

  @override
  String get unfavorite => 'Unfavorit';

  @override
  String get unfavoriteSelected => 'Nicht als Favorit ausgewählt';

  @override
  String get uniqueArtists => 'Einzigartige Künstler';

  @override
  String get universalCompatibility => 'Universelle Kompatibilität';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get unknownAlbum => 'Unbekanntes Album';

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String get unknownBitrate => 'Unbekannte Bitrate';

  @override
  String get unknownFolder => 'Unbekannter Ordner';

  @override
  String get unknownTitle => 'Unbekannter Titel';

  @override
  String get unknownTrack => 'Unbekannter Track';

  @override
  String unlocked(Object unlocked, Object arg1) {
    return '$unlocked / $arg1 freigeschaltet';
  }

  @override
  String get unmute => 'Stummschaltung aufheben';

  @override
  String get unreported => 'Nicht gemeldet';

  @override
  String get unsavedChanges => 'Nicht gespeicherte Änderungen';

  @override
  String up(Object arg1) {
    return '$arg1 oben';
  }

  @override
  String get upNext => 'Als nächstes';

  @override
  String upcomingSong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kommende Songs',
      one: '$count kommender Song',
    );
    return '$_temp0';
  }

  @override
  String get update => 'Aktualisieren';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String get updateNoticeHidden => 'Update-Hinweis ausgeblendet.';

  @override
  String updated(Object arg1) {
    return 'Aktualisiert $arg1';
  }

  @override
  String updatedAlbumArtFor(Object arg1) {
    return 'Aktualisiertes Albumcover für „$arg1“.';
  }

  @override
  String updatedAlbumArtFor2(Object arg1) {
    return 'Aktualisiertes Albumcover für „$arg1“.';
  }

  @override
  String get upload => 'Hochladen';

  @override
  String uploadFailed(Object arg1) {
    return 'Hochladen fehlgeschlagen ($arg1).';
  }

  @override
  String uploadFailed2(Object e) {
    return 'Hochladen fehlgeschlagen: $e';
  }

  @override
  String get uploadLogsAsALink => 'Protokolle als Link hochladen?';

  @override
  String get upnpDlna => 'UPnP / DLNA';

  @override
  String get urbPacket => 'URB-Paket';

  @override
  String get urbTransfer => 'URB-Transfer';

  @override
  String get urbanEchoes => 'Städtische Echos';

  @override
  String get usbAudioDevice => 'USB-Audiogerät';

  @override
  String get usbAudioDevices => 'USB-Audiogeräte';

  @override
  String get usbAudioError => 'USB-Audiofehler';

  @override
  String get usbDacAutoBitPerfectOffers =>
      'Der automatische Bit-Perfekt-Reset des USB-DAC bietet einen Reset.';

  @override
  String get usbNotConnected => 'USB nicht angeschlossen';

  @override
  String get usbRouteVolume => 'USB-Route-Volume';

  @override
  String get usbVolume => 'USB-Lautstärke';

  @override
  String get useAFixed48khz16bitOutput =>
      'Verwenden Sie für eine bessere Kompatibilität einen festen 48-kHz-/16-Bit-Ausgang';

  @override
  String get useAaudioDirectlyLowestLatencyOn =>
      'Verwenden Sie AAudio direkt. Niedrigste Latenz unter Android 8.1 und neuer.';

  @override
  String get useAlbumArtAsBackground =>
      'Verwenden Sie Albumcover als Hintergrund';

  @override
  String get useAutoSource => 'Verwenden Sie die automatische Quelle';

  @override
  String get useCurrentTime => 'Aktuelle Zeit verwenden';

  @override
  String get useExistingFile => 'Vorhandene Datei verwenden';

  @override
  String get useExistingFileInTheLyrics =>
      '- „Vorhandene Datei verwenden“ im Textfeld verlinkt an `.lrc`, `.txt`, oder `.xml` Datei.\n- Wenn einige Zeilen nicht gestempelt sind, Hadoo füllen ihre Zeiten automatisch aus.\n- Speichern schreibt nach Möglichkeit neben das Lied, andernfalls Hadoo speichert eine verknüpfte Kopie.';

  @override
  String get useMmSsCcEG => 'Verwenden Sie mm:ss.cc, z.B. 01:23.45';

  @override
  String get useTheDefaultMonochromeTheme =>
      'Verwenden Sie das standardmäßige monochrome Design.';

  @override
  String get useTheHighestFixedOutputRate =>
      'Verwenden Sie die höchste verfügbare feste Ausgaberate und Bittiefe';

  @override
  String get useTheLegacyOpenslEsBackend =>
      'Verwenden Sie das ältere OpenSL ES-Backend. Fehlerbehebung bei älteren oder problematischen Geräten.';

  @override
  String get useTheVerifiedDirectUsbPath =>
      'Verwenden Sie den verifizierten direkten USB-Pfad und deaktivieren Sie Software-DSP-Steuerungen, die die bitgenaue Wiedergabe auf einem externen USB-DAC beeinträchtigen würden.';

  @override
  String get userToken => 'Benutzertoken';

  @override
  String get username => 'Benutzername';

  @override
  String get variableBitrateLowLatency => 'Variable Bitrate, geringe Latenz';

  @override
  String get variousArtists2 => 'Verschiedene Künstler';

  @override
  String get velvetNoir => 'Samt Noir';

  @override
  String get vendorId => 'Anbieter-ID';

  @override
  String get verboseDartRustAndCrashLogs =>
      'Ausführliche Dart-, Rust- und Absturzprotokolle';

  @override
  String get verified => 'Verifiziert';

  @override
  String version2(Object arg1) {
    return 'Version $arg1';
  }

  @override
  String get verticalBarsClassicSpectrumAnalyzer =>
      'Vertikale Balken – klassischer Spektrumanalysator';

  @override
  String get verticalBarsThatAnimateAcrossThe =>
      'Vertikale Balken, die über den Bildschirm animiert werden.';

  @override
  String get vibrant => 'Lebendig';

  @override
  String get viewAsGrid => 'Als Raster anzeigen';

  @override
  String get viewAsList => 'Als Liste anzeigen';

  @override
  String get viewMetadata => 'Metadaten anzeigen';

  @override
  String get viewQueue => 'Warteschlange anzeigen';

  @override
  String get visualizer => 'Visualisierung';

  @override
  String get visualizerAlbumColorsDescription =>
      'Befolgen Sie die Farben des Albumcovers. Monochrom, wenn nicht verfügbar';

  @override
  String get visualizerBlocks => 'Verblassende Blöcke';

  @override
  String get visualizerBlocksDescription =>
      'Segmentierte Balken mit sanft ausklingenden Spuren';

  @override
  String get visualizerColors => 'Farben';

  @override
  String get visualizerMonochrome => 'Monochrom';

  @override
  String get visualizerMonochromeDescription =>
      'Weiß und Grau, unabhängig vom Albumcover';

  @override
  String get visualizerRainbow => 'Regenbogen';

  @override
  String get visualizerRainbowDescription =>
      'Ein Farbspektrum im gesamten Visualizer';

  @override
  String get volume => 'Lautstärke';

  @override
  String get volumeControl => 'Lautstärkeregelung';

  @override
  String get volumeIsFixedWhileBitPerfect =>
      'Die Lautstärke ist fest eingestellt, während Bit-Perfect-Passthrough aktiv ist und dieser DAC über keine Hardware-Lautstärkeregelung verfügt.';

  @override
  String get volumeIsFixedWhileBitPerfect2 =>
      'Die Lautstärke ist fixiert, während bit-perfektes Passthrough aktiv ist: Der Stream wird unverändert gesendet und dieser DAC verfügt über keine Hardware-Lautstärkeregelung.';

  @override
  String wAgo(Object arg1) {
    return 'Vor ${arg1}w';
  }

  @override
  String get waitingForBrowserAuthorization =>
      'Warten auf Browser-Autorisierung...';

  @override
  String get waitingForPlayback => 'Warten auf Wiedergabe';

  @override
  String get wantEveryControlDocumentedOpenThe =>
      'Möchten Sie, dass jede Kontrolle dokumentiert wird? Öffnen Sie das In-App-Handbuch jederzeit über Einstellungen → Hilfe und Handbuch.';

  @override
  String was(Object arg1) {
    return 'war: $arg1';
  }

  @override
  String get wave => 'Welle';

  @override
  String get waveform => 'Wellenform';

  @override
  String weLlKeepTheBestQuality(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kopien',
      one: '$count kopieren',
    );
    return 'Wir behalten in jeder Gruppe die Version mit der besten Qualität (bevorzugt Albumcover, dann höchste Bitrate) und entfernen sie $_temp0. Dateien auf der Festplatte werden nicht gelöscht.';
  }

  @override
  String weLlKeepYourCheckedVersion(int kept, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      kept,
      locale: localeName,
      other: '$kept geprüfte Versionen',
      one: '$kept geprüfte Version',
    );
    String _temp1 = intl.Intl.pluralLogic(
      removed,
      locale: localeName,
      other: '$removed Kopien',
      one: '$removed kopieren',
    );
    return 'Wir behalten Ihr $_temp0 und den anderen entfernen $_temp1 aus Ihrer Bibliothek. Audiodateien auf der Festplatte werden nicht gelöscht.';
  }

  @override
  String get webdav => 'WebDAV';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get welcomeBackLetSStartA =>
      'Willkommen zurück – lasst uns einen Streak beginnen.';

  @override
  String get welcomeToFlick => 'Willkommen bei Hadoo!';

  @override
  String get welcomeToFlick2 => 'Willkommen bei Hadoo';

  @override
  String get whatSNew => 'Was ist neu?';

  @override
  String get whenYouPlayOverBluetoothAndroid =>
      'Wenn Sie über Bluetooth spielen, handelt Android den Codec mit Ihren Kopfhörern oder Lautsprechern aus.';

  @override
  String get whereShouldTheLrcFileBe =>
      'Wo soll die .lrc-Datei gespeichert werden?';

  @override
  String get whisperWorld => 'Flüsterwelt';

  @override
  String get whisperedSecrets => 'Geflüsterte Geheimnisse';

  @override
  String get white => 'Weiß';

  @override
  String get wholeAlbum => 'Ganzes Album';

  @override
  String wide(Object amount) {
    return '$amount% breit';
  }

  @override
  String get widgets => 'Widgets';

  @override
  String get width => 'Breite';

  @override
  String get wildWeather => 'Wildes Wetter';

  @override
  String get willBeRemoved => 'Wird entfernt';

  @override
  String get willKeep => 'Werde behalten';

  @override
  String get wiredOutput => 'Kabelgebundener Ausgang';

  @override
  String word(Object arg1, Object arg2) {
    return 'Wort $arg1 · „$arg2“';
  }

  @override
  String word2(Object arg1, Object token) {
    return 'Wort $arg1 · „$token“';
  }

  @override
  String get wordSync => 'Word-Synchronisierung';

  @override
  String get wordSyncModeKaraoke => 'Word-Sync-Modus (Karaoke)';

  @override
  String wordTimelineLine(Object arg1) {
    return 'Word-Zeitleiste · Zeile $arg1';
  }

  @override
  String get writeADescription => 'Schreiben Sie eine Beschreibung';

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
    return 'Vor ${arg1}y';
  }

  @override
  String get year => 'Jahr';

  @override
  String get yearly => 'Jährlich';

  @override
  String get yesterday => 'Gestern';

  @override
  String get youCanAlsoChangeTheCodec =>
      'Sie können den Codec auch in den Android-Entwickleroptionen unter „Bluetooth Audio Codec“ ändern.';

  @override
  String get youCustomizedWhichVersionsToKeep =>
      'Sie haben angepasst, welche Versionen beibehalten werden sollen. Schön – Sie haben die Kontrolle.';

  @override
  String get youHaveUnsavedChangesAreYou =>
      'Sie haben nicht gespeicherte Änderungen. Sind Sie sicher, dass Sie sie verwerfen möchten?';

  @override
  String get youHaveUnsavedLyricEditsLeave =>
      'Sie haben Textänderungen nicht gespeichert. Sync Studio ohne Speichern verlassen?';

  @override
  String get youReOffline => 'Du bist offline';

  @override
  String get youReOfflineSomeOnlineFeatures =>
      'Du bist offline. Einige Online-Funktionen funktionieren möglicherweise nicht.';

  @override
  String get youVeHitTheThresholdKeep =>
      'Sie haben die Schwelle erreicht – machen Sie weiter so!';

  @override
  String get yourCollectionAtAGlance => 'Ihre Sammlung auf einen Blick';

  @override
  String get yourCustomCollections => 'Ihre individuellen Kollektionen';

  @override
  String get yourHeaviestRotationRightNow => 'Deine derzeit schwerste Rotation';

  @override
  String get yourLatestLibraryScans => 'Ihre neuesten Bibliotheksscans';

  @override
  String get yourLibrary => 'Ihre Bibliothek';

  @override
  String get yourLibraryAtAGlance => 'Ihre Bibliothek auf einen Blick';

  @override
  String get yourLibraryIsTidyWeLl =>
      'Ihre Bibliothek ist aufgeräumt. Wir informieren Sie, wenn nach dem nächsten Scan neue Duplikate auftauchen.';

  @override
  String get yourListeningHistoryIsStillYours =>
      'Ihr Hörverlauf gehört weiterhin Ihnen. Versuchen Sie es erneut zu laden.';

  @override
  String get yourListensWillRemainOnListenbrainz =>
      'Ihre Listen bleiben auf ListenBrainz, aber Hadoo sendet sie nicht mehr.';

  @override
  String get yourLogsAreUploadedToDpaste =>
      'Ihre Protokolle werden als nicht gelisteter Link, der nach 30 Tagen abläuft, auf dpaste.com hochgeladen. Jeder, mit dem Sie den Link teilen, kann sie lesen – Protokolle können Dateipfade und Gerätedetails enthalten.';

  @override
  String get yourMonthlyRecapNeedsABit =>
      'Ihre monatliche Zusammenfassung benötigt diesen Monat etwas mehr Zeit zum Hören.';

  @override
  String get yourMostReplayedTrack => 'Ihr am häufigsten wiedergegebener Titel';

  @override
  String get yourMusicIsBeingScrobbled => 'Deine Musik wird gescrobbelt';

  @override
  String get yourMusicIsBeingSubmitted => 'Ihre Musik wird eingereicht';

  @override
  String get yourMusicOnRepeat => 'Deine Musik. Bei Wiederholung.';

  @override
  String get yourNewAudioEngineIsReady =>
      'Ihre neue Audio-Engine ist fertig. Starten Sie Hadoo neu, um es anzuwenden.';

  @override
  String get yourNextFavoriteIsWaiting => 'Ihr nächster Favorit wartet.';

  @override
  String get yourNextFavoriteNisWaiting => 'Ihr nächster Favorit\nwartet.';

  @override
  String get yourPlaylists => 'Ihre Playlists';

  @override
  String get yourScrobblingHistoryWillRemainOn =>
      'Ihr Scrobbelverlauf bleibt auf Last.fm bestehen, Hadoo sendet jedoch keine Scrobbles mehr.';

  @override
  String get yourSessionHistory => 'Ihr Sitzungsverlauf';

  @override
  String get yourWeeklyRecapAppearsOnceYou =>
      'Ihre wöchentliche Zusammenfassung erscheint, sobald Sie diese Woche mit dem Hören beginnen.';

  @override
  String get yourWholeLibraryLivesHereTap =>
      'Ihre gesamte Bibliothek lebt hier. Tippen Sie auf ein beliebiges Lied, um es abzuspielen.';

  @override
  String get yourYearlyRecapFillsInAs =>
      'Ihre jährliche Zusammenfassung füllt sich, während Sie das ganze Jahr über weiter zuhören.';

  @override
  String get linkDesktop => 'Desktop-Link';

  @override
  String get linkDevices => 'Geräte';

  @override
  String get linkConnectDesktop => 'Schließen Sie Ihren Hadoo-Desktop an';

  @override
  String get linkPairingHint =>
      'Öffnen Sie auf Ihrem Desktop „Phone Remote“ und wählen Sie „Ein Telefon koppeln“. Halten Sie beide Geräte im selben WLAN.';

  @override
  String get linkScanQr => 'Scannen Sie den Pairing-QR-Code';

  @override
  String get linkInvalidQr => 'Dies ist kein gültiger Hadoo-Pairing-Code.';

  @override
  String get linkCameraUnavailable =>
      'Der Zugriff auf die Kamera ist nicht möglich. Gehen Sie zurück und geben Sie stattdessen die Desktop-Adresse und den Kopplungscode ein.';

  @override
  String get linkSearchDesktops => 'Finden Sie Desktops über WLAN';

  @override
  String get linkSearching => 'Auf der Suche nach Desktops…';

  @override
  String get linkNoDesktopFound =>
      'Kein Desktop gefunden. Sie können die Adresse manuell eingeben.';

  @override
  String get linkDesktopAddress => 'Desktop-Adresse';

  @override
  String get linkPairingCode => 'Sechsstelliger Kopplungscode';

  @override
  String get linkPair => 'Desktop koppeln';

  @override
  String get linkConnecting => 'Verbindung wird hergestellt…';

  @override
  String get linkMatchTheme => 'Passen Sie das Desktop-Thema und den Akzent an';

  @override
  String get linkConnected => 'Verbunden';

  @override
  String get linkOffline => 'Offline';

  @override
  String get linkReconnect => 'Erneut verbinden';

  @override
  String get linkDisconnect => 'Trennen';

  @override
  String get linkForget => 'Vergessen Sie den Desktop';

  @override
  String get linkForgetDescription =>
      'Gespeicherte Anmeldeinformationen dieses Desktops von diesem Telefon entfernen? Ihre Musik und die zusammengeführte Bibliothek bleiben auf diesem Telefon.';

  @override
  String get linkActionFailed =>
      'Der Desktop-Link konnte diese Aktion nicht abschließen.';

  @override
  String get linkPlayback => 'Wiedergabeausgabe';

  @override
  String get linkControlDesktop =>
      'Steuern Sie den Desktop über die aktuelle Wiedergabe';

  @override
  String get linkPlayOnDesktop => 'Spielen Sie auf dem Desktop';

  @override
  String get linkPlayOnPhone => 'Spielen Sie auf diesem Telefon';

  @override
  String get linkUpdateDesktop =>
      'Aktualisieren Sie Hadoo auf Ihrem PC, um dieses Telefon von dort aus zu steuern und Ihre Bibliothek zu synchronisieren.';

  @override
  String get linkMergeLibraries => 'Führen Sie Ihre Bibliotheken zusammen';

  @override
  String get linkMergePreview =>
      'Behalten Sie Musik, Likes und Playlists von beiden Geräten. Abgeschlossene Spiele werden einmal zusammengefasst. Es werden keine Musikdateien gelöscht. Spätere Bearbeitungen werden in beide Richtungen synchronisiert.';

  @override
  String get linkMerge => 'Zusammenführen';

  @override
  String get linkNotNow => 'Nicht jetzt';

  @override
  String linkHistoryCount(int count) {
    return '$count Desktop-Spiele bereit zum Zusammenführen';
  }

  @override
  String get linkSendDownloads => 'Telefon-Downloads an den PC senden';

  @override
  String get linkSendDownloadsDescription =>
      'Neue Downloads und bei der Wiedergabeübergabe fehlende Titel auf den gekoppelten PC kopieren. Die Originale bleiben auf diesem Telefon.';

  @override
  String get linkLegacyRemote =>
      'Stellen Sie manuell eine Verbindung zu einem älteren Desktop her';

  @override
  String get linkDownloadToPhone => 'Auf das Telefon herunterladen';

  @override
  String get linkDownloaded => 'Auf diesem Telefon gespeichert';

  @override
  String linkOutputName(String name) {
    return 'Hadoo auf $name';
  }

  @override
  String get linkOnboardingDescription =>
      'Steuern Sie beide Geräte, verschieben Sie Ihre Warteschlange zwischen ihnen und behalten Sie Likes, Playlists und den Hörverlauf bei. Dies ist optional und kann später eingerichtet werden.';

  @override
  String get linkFollowAccent => 'Folgen Sie dem App-Akzent';

  @override
  String get linkPerformanceTitle => 'Animationen flüssiger gestalten?';

  @override
  String get linkPerformanceBody =>
      'Der Leistungsmodus behält Ihr Thema bei und verwendet feste Oberflächen anstelle von Glas.';

  @override
  String get linkEnablePerformance => 'Verwenden Sie den Leistungsmodus';
}

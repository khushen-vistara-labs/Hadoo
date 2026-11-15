import 'package:flick/features/player/widgets/audio_signal_report.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/audio_engine_type.dart';
import 'package:flick/models/audio_output_diagnostics.dart';
import 'package:flick/models/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _song = Song(
  id: 'song',
  title: 'Test',
  artist: 'Artist',
  duration: Duration(minutes: 2),
  fileType: 'FLAC',
  sampleRate: 96000,
  bitDepth: 24,
);

const _flags = AudioCapabilityFlags(
  supportsExclusiveUsbOwnership: true,
  supportsDirectSampleRateSwitching: true,
  supportsVerifiedBitPerfect: true,
  supportsAndroidManagedHighResOnly: false,
  supportsInternalDapPathOnly: false,
);

AudioOutputDiagnostics _diagnostics(UrbTransportInfo? urb) =>
    AudioOutputDiagnostics(
      selectedMode: AudioEngineType.values.first,
      initializedMode: null,
      detectedDap: false,
      detectedDapBrand: null,
      pathManagement: AudioPathManagement.directUsbExperimental,
      outputStrategyLabel: 'Direct USB',
      capabilityStateLabel: 'Ready',
      backendDescription: 'Rust',
      routeType: 'usb',
      routeLabel: 'USB DAC',
      outputDeviceLabel: 'DAC',
      isMixerManaged: false,
      audioFocusHeld: true,
      directUsbRegistered: true,
      usbInterfaceClaimed: true,
      usbStreamStable: true,
      trackSampleRate: 96000,
      requestedOutputSampleRate: 96000,
      reportedOutputSampleRate: 96000,
      resamplerActive: false,
      passthroughAllowed: true,
      activeOutputSignature: null,
      verificationReason: null,
      fallbackReason: null,
      capabilityFlags: _flags,
      urbTransport: urb,
    );

Future<void> _mount(
  WidgetTester tester, {
  required AudioSignalReportPage page,
  Song song = _song,
  AudioOutputDiagnostics? diagnostics,
  bool expanded = true,
  double width = 320,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: expanded ? 480 : 100,
            child: AudioSignalReport(
              song: song,
              diagnostics: diagnostics,
              page: page,
              expanded: expanded,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => LocaleController.instance.bindLocale(const Locale('en')));
  tearDown(() => LocaleController.instance.bindLocale(const Locale('en')));

  testWidgets('source only reports file properties and distinguishes DSD', (
    tester,
  ) async {
    await _mount(tester, page: AudioSignalReportPage.source);
    expect(find.text('FLAC'), findsWidgets);
    expect(find.text('96.0 kHz'), findsOneWidget);
    expect(find.text('24-bit'), findsOneWidget);
    expect(find.text('Sample rate'), findsOneWidget);
    expect(tester.takeException(), isNull);

    const dsd = Song(
      id: 'dsd',
      title: 'DSD',
      artist: 'Artist',
      duration: Duration(minutes: 2),
      fileType: 'DSF',
      sampleRate: 2822400,
    );
    await _mount(tester, page: AudioSignalReportPage.source, song: dsd);
    expect(find.text('DSD bit rate'), findsOneWidget);
    expect(find.text('1-bit DSD'), findsOneWidget);
    expect(find.text('DSF · DSD64'), findsOneWidget);
    expect(find.text('Raw PCM'), findsNothing);
  });

  testWidgets('USB unavailable and snapshot values never invent measurements', (
    tester,
  ) async {
    await _mount(tester, page: AudioSignalReportPage.urb, expanded: false);
    expect(find.text('USB transport details unavailable'), findsOneWidget);
    expect(find.text('No URB data'), findsOneWidget);

    await _mount(
      tester,
      page: AudioSignalReportPage.urb,
      diagnostics: _diagnostics(
        const UrbTransportInfo(
          activeEndpointAddress: 1,
          transportFormat: 'PCM',
          activeMaxPacketBytes: 512,
          bufferFillMs: 7,
          bufferTargetMs: 10,
          bufferCapacityMs: 20,
          underrunCount: 0,
        ),
      ),
    );
    expect(find.textContaining('not a live packet trace'), findsOneWidget);
    expect(find.text('0x01'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Max packet'), 180);
    expect(find.text('512 B'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Buffer fill'), 180);
    expect(find.text('7 ms'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Buffer occupancy at open'), 180);
    expect(find.text('Buffer occupancy at open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese copy renders and compact pages fit narrow screens', (
    tester,
  ) async {
    LocaleController.instance.bindLocale(const Locale('zh', 'CN'));
    await _mount(tester, page: AudioSignalReportPage.source, width: 280);
    expect(find.text(l10n.signalSourceDescription), findsOneWidget);
    expect(
      find.text(
        'Properties of the source file, not the output sent to the device.',
      ),
      findsNothing,
    );
    for (final page in AudioSignalReportPage.values) {
      await _mount(tester, page: page, expanded: false, width: 280);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('URB missing buffer values do not produce an occupancy meter', (
    tester,
  ) async {
    await _mount(
      tester,
      page: AudioSignalReportPage.urb,
      diagnostics: _diagnostics(const UrbTransportInfo()),
    );
    expect(find.text('Not reported'), findsWidgets);
    expect(find.text('Buffer occupancy at open'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recorded distinguishes missing, matching and mismatched rip evidence',
    (tester) async {
      await _mount(
        tester,
        page: AudioSignalReportPage.recorded,
        expanded: false,
      );
      expect(find.text('No rip data'), findsOneWidget);
      await _mount(
        tester,
        page: AudioSignalReportPage.recorded,
        song: _song.copyWith(ripper: '   '),
        expanded: false,
      );
      expect(find.text('No rip data'), findsOneWidget);

      final matching = _song.copyWith(
        testCrc: 'aBcD',
        copyCrc: 'ABCD',
        accurateRip: true,
      );
      await _mount(
        tester,
        page: AudioSignalReportPage.recorded,
        song: matching,
      );
      await tester.scrollUntilVisible(find.text('AccurateRip'), 180);
      expect(find.text('Match'), findsOneWidget);
      expect(find.text('Verified in log'), findsOneWidget);

      final mismatched = _song.copyWith(
        testCrc: 'ABCD',
        copyCrc: '1234',
        accurateRip: false,
      );
      await _mount(
        tester,
        page: AudioSignalReportPage.recorded,
        song: mismatched,
      );
      expect(find.text('Mismatch'), findsOneWidget);
      expect(find.text('Not verified'), findsOneWidget);

      final incomplete = _song.copyWith(testCrc: 'ABCD');
      await _mount(
        tester,
        page: AudioSignalReportPage.recorded,
        song: incomplete,
      );
      expect(find.text('Cannot compare'), findsOneWidget);
      expect(find.text('Not reported'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

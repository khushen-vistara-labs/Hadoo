import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flick/services/atmos_dec3_probe.dart';
import 'package:flick/services/atmos_playback_support.dart';

Uint8List box(String type, List<int> payload) {
  final size = payload.length + 8;
  return Uint8List.fromList([
    (size >> 24) & 255, (size >> 16) & 255, (size >> 8) & 255, size & 255,
    ...ascii.encode(type), ...payload,
  ]);
}

List<int> dec3({bool joc = true, int complexity = 12}) => [
  0, 0,  // data_rate=0, num_ind_sub=0
  0, 0, 0, // one descriptor, num_dep_sub=0
  joc ? 1 : 0, complexity,
];

Uint8List mp4({
  bool joc = true,
  bool includeDec3 = true,
  String sampleEntry = 'ec-3',
  bool dec3InMdatOnly = false,
  bool malformedDec3 = false,
}) {
  final descriptor = box('dec3',
      malformedDec3 ? [0, 0, 0] : dec3(joc: joc));
  final ec3 = box(sampleEntry, [
    ...List<int>.filled(28, 0),
    if (includeDec3 && !dec3InMdatOnly) ...descriptor,
  ]);
  final stsd = box('stsd', [0, 0, 0, 0, 0, 0, 0, 1, ...ec3]);
  final moov = box('moov',
      box('trak', box('mdia', box('minf', box('stbl', stsd)))));
  final mdat = box('mdat', dec3InMdatOnly ? descriptor : [1, 2, 3, 4]);
  return Uint8List.fromList([...mdat, ...moov]); // moov at end
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('lokal/atmos');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('atmos-dec3-');
    messenger.setMockMethodCallHandler(channel, (_) async => false);
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    await dir.delete(recursive: true);
  });

  Future<String> stage(List<int> bytes) async {
    final file = File('${dir.path}/download.m4a');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  test('real MP4 JOC signaling verifies when both Android and FFprobe only report E-AC-3', () async {
    final path = await stage(mp4());
    final parsed = await inspectAtmosDec3(path);
    expect(parsed.verified, true);
    expect(parsed.ec3SampleEntry, true);
    expect(parsed.dec3Present, true);
    expect(parsed.reason, 'dec3_joc_confirmed');
    expect(await AtmosPlaybackSupport.isJocFile(path,
      probeStreams: (_) async => [
        {'codec_type': 'audio', 'codec_name': 'eac3',
         'profile': 'Dolby Digital Plus'},
      ]), true);
  });

  test('ordinary E-AC-3 must not be mislabeled as Atmos', () async {
    final path = await stage(mp4(joc: false));
    final parsed = await inspectAtmosDec3(path);
    expect(parsed.verified, false);
    expect(parsed.reason, 'dec3_joc_not_signalled');
    expect(await AtmosPlaybackSupport.isJocFile(path,
      probeStreams: (_) async => [
        {'codec_type': 'audio', 'codec_name': 'eac3',
         'profile': 'Dolby Digital Plus'},
      ]), false);
  });

  test('JOC flag in mdat or AAC entry is not enough', () async {
    var path = await stage(mp4(dec3InMdatOnly: true));
    expect((await inspectAtmosDec3(path)).verified, false);
    path = await stage(mp4(sampleEntry: 'mp4a'));
    expect((await inspectAtmosDec3(path)).verified, false);
  });

  test('invalid, truncated, or missing dec3 stays unverified', () async {
    var path = await stage(mp4(malformedDec3: true));
    expect((await inspectAtmosDec3(path)).verified, false);
    path = await stage(mp4(includeDec3: false));
    expect((await inspectAtmosDec3(path)).verified, false);
    path = await stage([0, 0, 0, 128, 109, 111, 111, 118]);
    expect((await inspectAtmosDec3(path)).verified, false);
  });

  test('complexity must be 1 through 16', () {
    expect(ec3SpecificBoxHasJoc(Uint8List.fromList(dec3())), true);
    expect(ec3SpecificBoxHasJoc(Uint8List.fromList(dec3(joc: false))), false);
    expect(ec3SpecificBoxHasJoc(Uint8List.fromList(dec3(complexity: 0))), false);
    expect(ec3SpecificBoxHasJoc(Uint8List.fromList(dec3(complexity: 17))), false);
  });

  test('confirmed FFprobe JOC profile still takes precedence', () async {
    final path = await stage(mp4(joc: false));
    expect(await AtmosPlaybackSupport.isJocFile(path,
      probeStreams: (_) async => [
        {'codec_type': 'audio', 'codec_name': 'eac3',
         'profile': 'Dolby Digital Plus + Dolby Atmos'},
      ]), true);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/features/discovery/discovery_progressive_streams.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';

void main() {
  final handles = DiscoveryProgressiveStreams.instance;
  setUp(handles.clear);
  tearDown(handles.clear);

  test('HTTP add-on starts with a direct progressive descriptor, not a staged download', () {
    final track = DiscoveryTrack(
      id: 'song', title: 'Direct audio', artist: 'Artist',
      source: DiscoverySource.addon,
    );
    final url = Uri.parse('https://cdn.example.net/song.flac?token=signed-private');
    final song = progressiveAddonSong(track, ResolvedDiscoveryAudio(url));
    expect(song.sourcePackage, 'konnekted.progressive');
    expect(song.fileType, 'FLAC');
    expect(song.filePath, startsWith('lokal-progressive://'));
    expect(song.filePath, isNot(contains('signed-private')));
    expect(handles.resolve(song.filePath), url);
  });

  test('two signed source URLs produce unique handles and are never persisted as raw URLs', () {
    final uri = Uri.parse('https://cdn.example.com/recording.mp3?token=secret');
    final a = handles.register(uri);
    final b = handles.register(uri);
    expect(a, isNot(b));
    expect(handles.resolve(a), uri);
    expect(handles.resolve(b), uri);
    expect(a, isNot(contains('cdn.example.com')));
    handles.clear();
    expect(handles.resolve(a), isNull);
  });

  test('unsafe direct URLs cannot be registered as progressive sources', () {
    expect(() => handles.register(Uri.parse('http://example.com/a.mp3')),
        throwsArgumentError);
    expect(() => handles.register(Uri.parse('https://u:p@example.com/a.mp3')),
        throwsArgumentError);
  });
}

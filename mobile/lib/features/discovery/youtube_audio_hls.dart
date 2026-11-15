import 'dart:convert';
import 'dart:typed_data';

import 'discovery_http.dart';
import 'discovery_models.dart';

Uri? _mediaUri(Uri? base, String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = Uri.tryParse(value);
  final uri = parsed == null ? null : (base?.resolveUri(parsed) ?? parsed);
  return uri != null &&
          uri.scheme == 'https' &&
          uri.userInfo.isEmpty &&
          uri.port == 443 &&
          uri.host.endsWith('.googlevideo.com')
      ? uri
      : null;
}

String? _attribute(String line, String name) =>
    RegExp('(?:[:,])$name="([^"]+)"(?=,|\$)').firstMatch(line)?.group(1);

Future<List<String>> _manifest(
  DiscoveryHttp http,
  Uri uri,
  Future<void>? cancel,
) async {
  final bytes = BytesBuilder(copy: false);
  await http.transfer(
    uri,
    maxBytes: 512 * 1024,
    deadline: const Duration(seconds: 3),
    onChunk: bytes.add,
    cancel: cancel,
  );
  return const LineSplitter()
      .convert(utf8.decode(bytes.takeBytes(), allowMalformed: true))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

/// Accept only an explicitly advertised audio rendition with a complete VOD
/// playlist. AVPlayer gets the original signed URL without rewritten headers.
Future<Uri?> resolveYoutubeAudioHls(
  DiscoveryHttp http,
  String? url, {
  Future<void>? cancel,
  required Future<void> Function(Uri segment) verifySegment,
}) async {
  final master = _mediaUri(null, url);
  if (master == null) return null;
  final lines = await _manifest(http, master, cancel);
  if (lines.firstOrNull != '#EXTM3U') return null;

  final audio = <Uri>{};
  for (var i = 0; i < lines.length && audio.length < 3; i++) {
    final line = lines[i];
    String? reference;
    if (line.startsWith('#EXT-X-MEDIA:') &&
        RegExp(r'[:,]TYPE=AUDIO(?:,|$)').hasMatch(line)) {
      reference = _attribute(line, 'URI');
    } else if (line.startsWith('#EXT-X-STREAM-INF:') &&
        i + 1 < lines.length &&
        (_attribute(
              line,
              'CODECS',
            )?.split(',').every((codec) => codec.trim().startsWith('mp4a.')) ??
            false)) {
      reference = lines[i + 1];
    }
    final uri = _mediaUri(master, reference);
    if (uri != null && uri.path.endsWith('.m3u8')) audio.add(uri);
  }

  for (final uri in audio) {
    try {
      final media = await _manifest(http, uri, cancel);
      if (media.firstOrNull != '#EXTM3U' ||
          !media.contains('#EXT-X-ENDLIST') ||
          !media.any((line) => line.startsWith('#EXTINF:'))) {
        continue;
      }
      final segments = media.where((line) => !line.startsWith('#')).toList();
      if (segments.isEmpty ||
          segments.any((line) => _mediaUri(uri, line) == null)) {
        continue;
      }
      if (media.any(
        (line) =>
            (line.startsWith('#EXT-X-KEY:') &&
                line != '#EXT-X-KEY:METHOD=NONE') ||
            (line.contains('URI=') &&
                _mediaUri(uri, _attribute(line, 'URI')) == null),
      )) {
        continue;
      }
      final first = _mediaUri(uri, segments.first)!;
      final last = _mediaUri(uri, segments.last)!;
      await verifySegment(first);
      if (last != first) await verifySegment(last);
      return uri;
    } on DiscoveryException catch (error) {
      if (error.message == 'Request cancelled.') rethrow;
    }
  }
  return null;
}

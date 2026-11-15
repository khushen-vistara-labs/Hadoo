import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/features/spotify/spotify_storage.dart';

import 'moving_cover_matcher.dart';

/// Uses the existing encrypted Spotify session; credentials only go to Spotify.
/// GraphQL is tried first, with the desktop protobuf Canvas endpoint as fallback.
class SpotifyCanvasService {
  SpotifyCanvasService({
    required this.client,
    SpotifyTokenStore? store,
    SpotifyOAuthService? oauth,
  }) : _store = store ?? SecureSpotifyTokenStore(),
       _oauth =
           oauth ??
           SpotifyOAuthService(tokenStore: store ?? SecureSpotifyTokenStore());
  final http.Client client;
  final SpotifyTokenStore _store;
  final SpotifyOAuthService _oauth;
  static const _searchHash =
      'bc1ca2fcd0ba1013a0fc88e6cc4f190af501851e3dafd3e1ef85840297694428';
  static const _canvasHash =
      '575138ab27cd5c1b3e54da54d0a7cc8d85485402de26340c2145f0f6bb5e7a9f';
  Future<http.Response> _request(
    Uri uri,
    SpotifyTokens tokens, {
    Object? json,
    List<int>? protobuf,
  }) async {
    if (uri.scheme != 'https' ||
        !{
          'api.spotify.com',
          'api-partner.spotify.com',
          'spclient.wg.spotify.com',
        }.contains(uri.host))
      throw StateError('Invalid Spotify origin');
    final abort = Completer<void>();
    final timer = Timer(const Duration(seconds: 12), () => abort.complete());
    final request = http.AbortableRequest(
      json != null || protobuf != null ? 'POST' : 'GET',
      uri,
      abortTrigger: abort.future,
    )..followRedirects = false;
    request.headers.addAll({
      'Authorization': 'Bearer ${tokens.accessToken}',
      'Accept': protobuf != null ? 'application/protobuf' : 'application/json',
      'App-Platform': 'WebPlayer',
      'User-Agent': protobuf != null
          ? 'Spotify/9.0.34.593 iOS/18.4 (iPhone15,3)'
          : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      if (protobuf == null) 'Origin': 'https://open.spotify.com',
      if (protobuf == null) 'Referer': 'https://open.spotify.com/',
      'Accept-Language': 'en',
      if (tokens.clientToken != null) 'client-token': tokens.clientToken!,
    });
    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    }
    if (protobuf != null) {
      request.headers['Content-Type'] = 'application/protobuf';
      request.bodyBytes = protobuf;
    }
    try {
      final response = await client.send(request);
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (bytes.length > 2 * 1024 * 1024)
          throw StateError('Spotify response too large');
      }
      return http.Response.bytes(
        bytes,
        response.statusCode,
        headers: response.headers,
      );
    } finally {
      timer.cancel();
    }
  }

  Map<String, dynamic> _json(http.Response response) {
    if (response.statusCode != 200)
      throw StateError('Spotify Canvas HTTP ${response.statusCode}');
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<String?> lookup({
    required String title,
    required String artist,
    String? album,
  }) async {
    var tokens = await _store.readTokens();
    if (tokens?.sessionCookie?.isNotEmpty != true) return null;
    if (tokens!.isExpired)
      tokens = await _oauth.refresh().timeout(const Duration(seconds: 50));
    if (tokens == null) throw StateError('Spotify session expired');
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _lookup(
          tokens!,
          title: title,
          artist: artist,
          album: album,
        );
      } catch (_) {
        if (attempt == 1) rethrow;
        tokens = await _oauth.refresh().timeout(const Duration(seconds: 50));
        if (tokens == null) rethrow;
      }
    }
    return null;
  }

  Future<String?> _lookup(
    SpotifyTokens tokens, {
    required String title,
    required String artist,
    String? album,
  }) async {
    List<Map> tracks = [];
    var searched = false;
    try {
      final rest = _json(
        await _request(
          Uri.https('api.spotify.com', '/v1/search', {
            'type': 'track',
            'limit': '10',
            'q':
                'track:${motionTitle(title)} artist:${motionArtists(artist).firstOrNull ?? artist}',
          }),
          tokens,
        ),
      );
      searched = true;
      tracks = (rest['tracks']?['items'] as List? ?? [])
          .whereType<Map>()
          .map(
            (v) => {
              'uri': v['uri'],
              'name': v['name'],
              'artists': (v['artists'] as List? ?? [])
                  .whereType<Map>()
                  .map((a) => a['name'])
                  .toList(),
              'album': v['album']?['name'],
            },
          )
          .toList();
    } catch (_) {
      /* Web-player tokens may only support Pathfinder. */
    }
    Map? pick() {
      final want = motionName(motionTitle(title));
      final matches = tracks
          .where(
            (t) =>
                (motionName(t['name']) == want ||
                    motionName(
                          t['name'].toString().replaceAll(
                            RegExp(r'\s+-\s+.*$'),
                            '',
                          ),
                        ) ==
                        want) &&
                motionArtistsMatch(artist, t['artists']),
          )
          .toList();
      return matches
              .where((t) => motionName(t['album']) == motionName(album))
              .firstOrNull ??
          matches.firstOrNull;
    }

    var hit = pick();
    if (hit == null) {
      final body = _json(
        await _request(
          Uri.https('api-partner.spotify.com', '/pathfinder/v2/query'),
          tokens,
          json: {
            'operationName': 'searchTracks',
            'variables': {
              'searchTerm': [
                motionTitle(title),
                artist,
                album,
              ].whereType<String>().where((s) => s.isNotEmpty).join(' '),
              'offset': 0,
              'limit': 10,
              'numberOfTopResults': 5,
              'includeAudiobooks': false,
              'includePreReleases': false,
            },
            'extensions': {
              'persistedQuery': {
                'version': 1,
                'sha256Hash': tokens.queryHashes['searchTracks'] ?? _searchHash,
              },
            },
          },
        ),
      );
      if (body['data'] == null && body['errors'] != null)
        throw StateError('Spotify search unavailable');
      searched = true;
      tracks = (body['data']?['searchV2']?['tracksV2']?['items'] as List? ?? [])
          .whereType<Map>()
          .map((v) => v['item']?['data'])
          .whereType<Map>()
          .map(
            (v) => {
              'uri': v['uri'],
              'name': v['name'],
              'artists': (v['artists']?['items'] as List? ?? [])
                  .whereType<Map>()
                  .map((a) => a['profile']?['name'])
                  .toList(),
              'album': v['albumOfTrack']?['name'],
            },
          )
          .toList();
      hit = pick();
    }
    if (!searched) throw StateError('Spotify search unavailable');
    final uri = hit?['uri']?.toString();
    if (uri == null ||
        !RegExp(r'^spotify:track:[a-zA-Z0-9]{22}$').hasMatch(uri))
      return null;
    try {
      final body = _json(
        await _request(
          Uri.https('api-partner.spotify.com', '/pathfinder/v2/query'),
          tokens,
          json: {
            'operationName': 'canvas',
            'variables': {'trackUri': uri},
            'extensions': {
              'persistedQuery': {
                'version': 1,
                'sha256Hash': tokens.queryHashes['canvas'] ?? _canvasHash,
              },
            },
          },
        ),
      );
      final canvas = validCanvasUrl(
        body['data']?['trackUnion']?['canvas']?['url'],
      );
      if (body['data'] != null) return canvas;
    } catch (_) {
      /* Try the older Canvas endpoint if GraphQL failed. */
    }
    final response = await _request(
      Uri.https('spclient.wg.spotify.com', '/canvaz-cache/v0/canvases'),
      tokens,
      protobuf: _field(1, _field(1, utf8.encode(uri))),
    );
    if (response.statusCode != 200)
      throw StateError('Spotify Canvas unavailable');
    return parseCanvasResponse(response.bodyBytes, uri);
  }

  static String? validCanvasUrl(Object? value) {
    final uri = Uri.tryParse(value?.toString() ?? '');
    return uri?.scheme == 'https' &&
            uri!.userInfo.isEmpty &&
            RegExp(r'\.mp4$', caseSensitive: false).hasMatch(uri.path)
        ? uri.toString()
        : null;
  }

  static List<int> _varint(int n) {
    final bytes = <int>[];
    while (n > 127) {
      bytes.add((n & 127) | 128);
      n >>= 7;
    }
    return [...bytes, n];
  }

  static List<int> _field(int number, List<int> bytes) => [
    ..._varint((number << 3) | 2),
    ..._varint(bytes.length),
    ...bytes,
  ];
  static Iterable<(int, List<int>)> _fields(List<int> bytes) sync* {
    var pos = 0;
    int read() {
      var n = 0, shift = 0;
      while (pos < bytes.length && shift < 56) {
        final b = bytes[pos++];
        n |= (b & 127) << shift;
        if (b < 128) return n;
        shift += 7;
      }
      throw const FormatException('Truncated protobuf');
    }

    while (pos < bytes.length) {
      final tag = read(), wire = tag & 7;
      if (wire == 0) {
        read();
      } else if (wire == 2) {
        final length = read();
        if (pos + length > bytes.length)
          throw const FormatException('Truncated protobuf');
        yield (tag >> 3, bytes.sublist(pos, pos + length));
        pos += length;
      } else if (wire == 1 || wire == 5) {
        pos += wire == 1 ? 8 : 4;
        if (pos > bytes.length)
          throw const FormatException('Truncated protobuf');
      } else {
        throw const FormatException('Unsupported protobuf');
      }
    }
  }

  static String? parseCanvasResponse(List<int> bytes, String wantedUri) {
    final found = <(String?, String)>[];
    try {
      for (final (tag, row) in _fields(bytes)) {
        if (tag != 1) continue;
        String? url, uri;
        for (final (field, value) in _fields(row)) {
          if (field == 2) url = validCanvasUrl(utf8.decode(value));
          if (field == 5) uri = utf8.decode(value);
        }
        if (url != null) found.add((uri, url));
      }
    } catch (_) {
      /* A changed/trailing protobuf field must not discard an earlier clip. */
    }
    if (found.isEmpty) {
      final match = RegExp(r'''https://[^"'\s\x00-\x1F]+\.cnvs\.mp4''')
          .firstMatch(latin1.decode(bytes, allowInvalid: true));
      final url = validCanvasUrl(match?.group(0));
      if (url != null) found.add((null, url));
    }
    return found.where((v) => v.$1 == wantedUri).firstOrNull?.$2 ??
        found.firstOrNull?.$2;
  }
}

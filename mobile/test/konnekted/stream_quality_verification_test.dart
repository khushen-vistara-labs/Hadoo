import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/services/catalogue_quality.dart';
import 'package:flutter_test/flutter_test.dart';

String fingerprint(Map<String, Object?> settings) =>
    sha256.convert(utf8.encode(jsonEncode(settings))).toString();

void main() {
  test('YouTube search badge comes from actual selected Opus/AAC source', () {
    for (final entry in [
      ('audio/webm; codecs="opus"', 'OPUS', 138000),
      ('audio/mp4; codecs="mp4a.40.2"', 'AAC', 128000),
    ]) {
      final codec = verifiedAudioCodec(entry.$1);
      expect(codec, entry.$2);
      expect(measuredLossyBitrate(codec: codec, bitsPerSecond: entry.$3),
          '${(entry.$3 / 1000).round()} kbps');
    }
    expect(verifiedAudioCodec('audio/webm'), isNull);
    expect(verifiedAudioCodec('video/mp4'), isNull);
  });

  test('quality change invalidates cache keys for every addon and tier', () {
    final providers = {
      'tidal': ['LOW', 'HIGH', 'LOSSLESS', 'HI_RES_LOSSLESS', 'DOLBY_ATMOS'],
      'qobuz': ['LOSSLESS', 'HI_RES_LOSSLESS'],
      'amazon': ['opus', 'best', 'DOLBY_ATMOS'],
      'custom-http': ['low', 'medium', 'high'],
      'deezer': ['FLAC'],
    };
    for (final entry in providers.entries) {
      final keys = <String>{};
      for (final option in entry.value) {
        keys.add(morneyePlaybackCacheKey(
          addonKey: entry.key,
          addonDigest: 'version-1',
          trackId: 'track-1',
          settingsFingerprint: fingerprint({'downloadQuality': option}),
          requestedTier: '',
        ));
      }
      expect(keys.length, entry.value.length, reason: entry.key);
    }
  });

  test('authorization is a recoverable pending-track condition, not a skip', () {
    const blocked = DiscoveryVerificationRequired('Tidal');
    expect(blocked, isA<DiscoveryException>());
    expect(blocked.message, contains('verification'));
  });
}

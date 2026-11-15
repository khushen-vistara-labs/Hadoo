import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flick/models/lokal_remote_state.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/link/lokal_desktop_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('fingerprints file bytes regardless of phone tags and sends only hashes to the paired PC', () async {
    final root = await Directory.systemTemp.createTemp('original-match');
    try {
      final bytes = List.generate(1024, (i) => i % 256);
      final file = await File('${root.path}/organized.flac')
          .writeAsBytes(bytes);
      var requests = 0;
      final source = LokalDesktopSource(
        originalClientFactory: () => MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(request.url.path, '/api/remote/files/match');
          expect(request.headers['x-remote-token'], 'paired-token');
          expect(jsonDecode(request.body), {
            'items': [
              {
                'size': bytes.length,
                'sha256': sha256.convert(bytes).toString(),
              },
            ],
          });
          return http.Response(
            '{"matches":[{"index":0,"trackId":"pc-original"}]}',
            200,
          );
        }),
      );
      final fingerprint = await source.originalFingerprint(
        Song(
          id: '42',
          title: 'Edited title',
          artist: 'Edited artist',
          fileType: 'FLAC',
          duration: Duration.zero,
          filePath: file.uri.toString(),
        ),
      );
      expect(fingerprint, {
        'size': bytes.length,
        'sha256': sha256.convert(bytes).toString(),
      });
      expect(
        await source.matchOriginalFingerprints(
          LokalRemoteCredentials(
            origin: Uri.parse('http://desktop.local:3000'),
            remoteToken: 'paired-token',
          ),
          [fingerprint!],
        ),
        {0: 'pc-original'},
      );
      expect(requests, 1);
      expect(await file.readAsBytes(), bytes);
    } finally {
      await root.delete(recursive: true);
    }
  });
  test('does not accept a comparison response pointing outside the submitted batch', () async {
    final source = LokalDesktopSource(
      originalClientFactory: () => MockClient(
        (_) async => http.Response(
          '{"matches":[{"index":1,"trackId":"unrelated"}]}',
          200,
        ),
      ),
    );
    await expectLater(
      source.matchOriginalFingerprints(
        LokalRemoteCredentials(
          origin: Uri.parse('http://desktop.local:3000'),
          remoteToken: 'paired-token',
        ),
        [
          {'size': 1, 'sha256': '0' * 64},
        ],
      ),
      throwsFormatException,
    );
  });
}

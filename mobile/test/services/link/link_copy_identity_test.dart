import 'package:flick/models/song.dart';
import 'package:flick/services/link/link_copy_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final identity = LinkCopyIdentity(
    serverId: 7,
    tracks: [
      {
        'id': 'original',
        'title': 'Original title',
        'artist': 'Original artist',
        'duration': 180,
      },
      {'id': 'scanned', 'title': 'Song', 'artist': 'Artist', 'duration': 200.4},
      {'id': 'alternate', 'title': 'Song', 'artist': 'Artist', 'duration': 205},
      {'id': 'unknown', 'title': 'Song', 'artist': 'Artist', 'duration': 0},
    ],
  );
  Song song({
    String title = 'Song',
    String artist = 'Artist',
    int seconds = 200,
    String? remoteId,
    int? server,
  }) => Song(
    id: 'phone-42',
    title: title,
    artist: artist,
    duration: Duration(seconds: seconds),
    fileType: 'FLAC',
    remoteServerId: server,
    remoteId: remoteId,
  );
  test(
    'copied originals match desktop identity after phone metadata changes',
    () {
      expect(
        identity.candidates(
          song(
            title: 'Edited title',
            seconds: 199,
            remoteId: 'original',
            server: 7,
          ),
        ),
        ['original'],
      );
    },
  );
  test(
    'bulk resolver uses fresh desktop identity and scopes it to the paired PC',
    () {
      expect(
        identity.resolverKey(
          song(
            title: 'Edited title',
            seconds: 199,
            remoteId: 'original',
            server: 7,
          ),
        ),
        'original artist|original title|180',
      );
      expect(
        identity.resolverKey(
          song(
            title: 'Edited title',
            seconds: 199,
            remoteId: 'original',
            server: 8,
          ),
        ),
        'artist|edited title|199',
      );
    },
  );
  test('an unrelated desktop ID is never trusted', () {
    expect(
      identity.candidates(
        song(title: 'Edited title', remoteId: 'original', server: 8),
      ),
      isEmpty,
    );
  });
  test('independently scanned copies use normalized metadata and duration', () {
    expect(identity.candidates(song(title: ' SONG ', artist: ' Artist  ')), [
      'scanned',
    ]);
  });
  test(
    'alternate recording, missing duration and artist mismatch stay eligible',
    () {
      expect(identity.candidates(song(seconds: 210)), isEmpty);
      expect(identity.candidates(song(seconds: 0)), isEmpty);
      expect(identity.candidates(song(artist: 'Other artist')), isEmpty);
    },
  );
  test('removed original identity does not hide a missing file', () {
    expect(
      identity.candidates(
        song(title: 'Edited title', remoteId: 'removed', server: 7),
      ),
      isEmpty,
    );
  });
}

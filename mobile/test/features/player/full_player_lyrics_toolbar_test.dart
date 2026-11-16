import 'package:flick/features/player/widgets/full_player_lyrics_toolbar.dart';
import 'package:flick/features/player/widgets/lyrics_save_button.dart';
import 'package:flick/features/player/widgets/lyrics_source_button.dart';
import 'package:flick/features/player/widgets/lyrics_subline_buttons.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/lyrics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all six lyric actions fit below the title on narrow phones', (
    tester,
  ) async {
    const song = Song(
      id: 'fixture',
      title: 'A song',
      artist: 'An artist',
      duration: Duration(minutes: 3),
      fileType: 'FLAC',
    );
    const lyrics = LyricsData(
      lines: [
        LyricsLine(
          timestamp: Duration.zero,
          text: 'Hello',
          words: [
            LyricsWord(
              start: Duration.zero,
              end: Duration(seconds: 1),
              text: 'Hello',
            ),
          ],
        ),
      ],
      isSynchronized: true,
      rawContent: '',
    );
    for (final width in [248.0, 314.0, 620.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: FullPlayerLyricsToolbar(
                    timing: lyricsTimingLabel(lyrics),
                    actions: [
                      LyricsSaveButton(saving: false, onSaveOriginal: () {}),
                      IconButton(
                        tooltip: 'Space',
                        onPressed: () {},
                        icon: const Icon(Icons.fullscreen),
                      ),
                      LyricsSourceButton(
                        selected: 'auto',
                        lyrics: lyrics,
                        song: song,
                        lyricsService: LyricsService(),
                        onSelected: (_) {},
                        onRefresh: () {},
                        iconOnly: true,
                      ),
                      LyricsSublineButtons(
                        lyrics: lyrics,
                        compactControls: true,
                        onChanged: (_) {},
                      ),
                      IconButton(
                        tooltip: 'Search online',
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final toolbar = tester.getRect(find.byType(FullPlayerLyricsToolbar));
      final title = tester.getRect(find.text(l10n.lyrics));
      final actions = find.byType(IconButton);
      expect(actions, findsNWidgets(6));
      for (var i = 0; i < 6; i++) {
        final button = tester.getRect(actions.at(i));
        expect(button.left, greaterThanOrEqualTo(toolbar.left));
        expect(button.right, lessThanOrEqualTo(toolbar.right));
        if (width < 500) expect(button.top, greaterThan(title.bottom));
      }
      expect(find.text(lyricsTimingLabel(lyrics)), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

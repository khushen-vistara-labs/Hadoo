import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'lyrics_service.dart';

/// Desktop's on-demand, marker-delimited translation/romanization protocol.
/// Cache by exact source text and target language, keeping source/timing intact.
class SameLyricsLanguage implements Exception {
  const SameLyricsLanguage();
}

class LyricsTranslationService {
  static bool sameLanguage(String? source, String target) {
    if (source == null || source.isEmpty) return false;
    final s = source.toLowerCase().replaceAll('_', '-');
    final t = target.toLowerCase().replaceAll('_', '-');
    if (s.startsWith('zh') && t.startsWith('zh')) return s == t;
    return s.split('-').first == t.split('-').first;
  }

  static final nonLatin = RegExp(
    r'[^\u0000-\u024F\u1E00-\u1EFF\s\p{P}\p{N}\p{S}]',
    unicode: true,
  );
  static final _marker = RegExp(r'\s*\uE000[^\uE001]*\uE001\s*');
  static Future<LyricsData?> convert(
    LyricsData lyrics, {
    required bool romanize,
    required String target,
    required bool Function() current,
  }) async {
    if (!romanize && sameLanguage(lyrics.language, target))
      throw const SameLyricsLanguage();
    final slots = <int>[
      for (var i = 0; i < lyrics.lines.length; i++)
        if (lyrics.lines[i].text.trim().isNotEmpty &&
            (!romanize || nonLatin.hasMatch(lyrics.lines[i].text)))
          i,
    ];
    if (slots.isEmpty) return null;
    final key =
        'lokal.lyrics.subline.v2.${sha256.convert(utf8.encode(jsonEncode([romanize, target, slots.map((i) => lyrics.lines[i].text).toList()])))}';
    final prefs = await SharedPreferences.getInstance();
    List<String>? answers = prefs.getStringList(key);
    var detected = prefs.getString('$key.language');
    final languages = <String, int>{};
    if (answers == null || answers.length != slots.length) {
      final batches = <List<int>>[];
      var batch = <int>[], size = 0;
      for (final i in slots) {
        final cost = lyrics.lines[i].text.length + 8;
        if (batch.isNotEmpty && size + cost > 3500) {
          batches.add(batch);
          batch = [];
          size = 0;
        }
        batch.add(i);
        size += cost;
      }
      if (batch.isNotEmpty) batches.add(batch);
      Future<List<String>?> request(List<int> indices) async {
        if (!current()) return null;
        final payload = [
          for (var k = 0; k < indices.length; k++)
            '${k == 0 ? '' : '\uE000${k.toString().padLeft(4, '0')}\uE001\n'}${lyrics.lines[indices[k]].text}',
        ].join('\n');
        for (final client in ['gtx', 'dict-chrome-ex']) {
          if (!current()) return null;
          try {
            final response = await http
                .post(
                  Uri.https('translate.googleapis.com', '/translate_a/single', {
                    'client': client,
                    'sl': 'auto',
                    'tl': romanize ? 'en' : target,
                    'dt': romanize ? 'rm' : 't',
                  }),
                  body: {'q': payload},
                )
                .timeout(const Duration(seconds: 12));
            if (response.statusCode != 200) continue;
            final root = jsonDecode(response.body);
            if (root is! List || root.isEmpty || root.first is! List) continue;
            if (root.length > 2 && root[2] is String) {
              final lang = root[2] as String;
              languages[lang] = (languages[lang] ?? 0) + payload.length;
            }
            final text = (root.first as List)
                .whereType<List>()
                .map(
                  (row) => row.length > (romanize ? 3 : 0)
                      ? row[romanize ? 3 : 0]?.toString() ?? ''
                      : '',
                )
                .join();
            final parts = text.split(_marker).map((s) => s.trim()).toList();
            if (parts.length == indices.length &&
                parts.any((s) => s.isNotEmpty))
              return parts;
          } catch (_) {
            /* Try the alternative public client, then report unavailable. */
          }
        }
        return null;
      }

      answers = [];
      for (var i = 0; i < batches.length; i += 2) {
        if (!current()) return null;
        final group = await Future.wait(batches.skip(i).take(2).map(request));
        if (group.any((answer) => answer == null)) return null;
        for (final answer in group) {
          answers.addAll(answer!);
        }
      }
      if (languages.isNotEmpty) {
        final ranked = languages.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        detected = ranked.first.key;
        await prefs.setString('$key.language', detected);
      }
      await prefs.setStringList(key, answers);
    }
    if (!current()) return null;
    if (!romanize && sameLanguage(detected, target))
      throw const SameLyricsLanguage();
    final result = <int, String>{
      for (var i = 0; i < slots.length; i++) slots[i]: answers[i],
    };
    return LyricsData(
      lines: [
        for (var i = 0; i < lyrics.lines.length; i++)
          lyrics.lines[i].withTranslation(result[i]),
      ],
      isSynchronized: lyrics.isSynchronized,
      source: lyrics.source,
      rawContent: lyrics.rawContent,
      language: lyrics.language ?? detected,
      translationLanguage: romanize ? null : target,
    );
  }
}

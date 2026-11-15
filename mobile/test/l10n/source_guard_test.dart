// Source-level guards for the localization traps that type checking cannot see.
//
// Every pattern below is here because it shipped a real bug:
//
//   A  a localized value used as a *key* -- `sectionOrder.indexOf(section.key)`
//      where sectionOrder had been rewritten to `l10n.today, ...`. The grouping
//      map is still keyed by the English labels, so every lookup missed: the
//      order was lost and the headers leaked English (fixed upstream in 52bcf55c).
//   C  a value that *holds* localized copy, inspected as if it were a token --
//      `_error!.startsWith('Camera')` while `_error` was
//      `l10n.cameraAccessIsNeeded...`. English worked, every translation lost the
//      button (fixed upstream in 318fce03).
//   P  a plural spelled with a ternary -- `count == 1 ? 'song' : 'songs'`, or
//      its suffix form `${count == 1 ? '' : 's'}`. Correct English and
//      untranslatable everywhere else.
//   W  localized copy used as a wire value -- `kAppVersionLabel` became an HTTP
//      User-Agent, and full-width punctuation is not a valid header value
//      (fixed upstream in 4cb94be3).
//
// Entries in l10n_allowlist.json under "source_guard" are keyed
// "<path>::<snippet>" and must carry a reason.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _sourceDir = 'lib';
const String _allowlistPath = 'test/l10n/l10n_allowlist.json';

class _Pattern {
  const _Pattern(this.id, this.expression, this.why);
  final String id;
  final String expression;
  final String why;
}

final List<_Pattern> _patterns = <_Pattern>[
  // ---------------------------------------------------------------- class A --
  _Pattern('A', r'indexOf\s*\(\s*l10n\.', 'a localized value used as a lookup key'),
  _Pattern('A', r'contains\s*\(\s*l10n\.', 'a localized value used as a lookup key'),
  _Pattern('A', r'indexWhere\s*\([^)]*l10n\.', 'a localized value used as a lookup key'),
  _Pattern('A', r'==\s*l10n\.\w+', 'comparing against localized copy'),
  _Pattern('A', r'l10n\.\w+\s*==', 'comparing against localized copy'),
  _Pattern('A', r'!=\s*l10n\.\w+', 'comparing against localized copy'),
  _Pattern('A', r'l10n\.\w+\s*!=', 'comparing against localized copy'),
  _Pattern('A', r'switch\s*\(\s*l10n\.', 'switching on localized copy'),
  _Pattern('A', r'case\s+l10n\.', 'switching on localized copy'),
  _Pattern('A', r'\[\s*l10n\.\w+\s*\]', 'a localized value used as a map key'),
  _Pattern('A', r'\{\s*l10n\.\w+\s*:', 'a localized value used as a map key'),

  // ------------------------------------------- class C: inspected localized --
  _Pattern('C', r'[A-Za-z_]\w*\s*[!?]{0,2}\s*\.\s*startsWith\s*\(\s*[\x27"]', 'inspecting localized copy'),
  _Pattern('C', r'[A-Za-z_]\w*\s*[!?]{0,2}\s*\.\s*endsWith\s*\(\s*[\x27"]', 'inspecting localized copy'),
  _Pattern('C', r'[A-Za-z_]\w*\s*[!?]{0,2}\s*\.\s*contains\s*\(\s*[\x27"]', 'inspecting localized copy'),

  // ----------------------------------------------------------- plural ternary --
  _Pattern('P', r'==\s*1\s*\?\s*[\x27"][^\x27"]*[\x27"]\s*:\s*[\x27"]', 'a plural spelled with a ternary'),
  _Pattern('P', r'!=\s*1\s*\?\s*[\x27"][^\x27"]*[\x27"]\s*:\s*[\x27"]', 'a plural spelled with a ternary'),

  // -------------------------------------------------------------- wire values --
  _Pattern('W', r'[\x27"](?:User-Agent|Authorization|SOAPAction|Accept|Content-Type)[\x27"]\s*:\s*l10n\.', 'localized copy as an HTTP header'),
  _Pattern('W', r'userAgent\s*:\s*l10n\.', 'localized copy as a user agent'),
];

/// A collection built from `l10n.*` that is later searched, switched on or
/// compared -- the `sectionOrder` bug, which no single-line pattern catches.
final RegExp _localizedCollection = RegExp(
  r'(?:final|var|const)\s+(\w+)\s*=\s*(?:const\s*)?[\[\{]([^;]*?)[\]\}]\s*;',
  dotAll: true,
);

final RegExp _collectionUse = RegExp(
  r'\b(\w+)\s*\.\s*(?:indexOf|indexWhere|contains)\s*\(',
);

Map<String, dynamic> _allowlist() =>
    (json.decode(File(_allowlistPath).readAsStringSync()) as Map<String, dynamic>)['source_guard']
        as Map<String, dynamic>;

List<_Finding> _scan() {
  final findings = <_Finding>[];
  for (final entity in Directory(_sourceDir).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (path.contains('/generated/')) continue;
    final source = entity.readAsStringSync();

    for (final pattern in _patterns) {
      if (pattern.id == 'C') continue; // needs the "assigned from l10n" evidence
      for (final match in RegExp(pattern.expression).allMatches(source)) {
        findings.add(_Finding(pattern.id, path, source, match));
      }
    }

    // class C, precisely: only identifiers this file really binds to l10n.
    final localizedNames = RegExp(r'\b([A-Za-z_]\w*)\s*(?:\?\?=|=)\s*[^;\n]{0,60}?\bl10n\.\w+')
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();
    if (localizedNames.isNotEmpty) {
      final inspect = RegExp(
        r'\b([A-Za-z_]\w*)\s*[!?]{0,2}\s*\.\s*(?:startsWith|endsWith|contains)\s*\(\s*[\x27"]'
        r'|'
        r'\b([A-Za-z_]\w*)\s*[!?]{0,2}\s*==\s*[\x27"]',
      );
      for (final match in inspect.allMatches(source)) {
        final name = match.group(1) ?? match.group(2) ?? '';
        if (localizedNames.contains(name)) {
          findings.add(_Finding('C', path, source, match));
        }
      }
    }

    // collections of l10n values that are used as keys
    for (final collection in _localizedCollection.allMatches(source)) {
      final name = collection.group(1)!;
      final body = collection.group(2)!;
      if (RegExp(r'l10n\.').allMatches(body).length < 2) continue;
      for (final use in _collectionUse.allMatches(source)) {
        if (use.group(1) != name) continue;
        if (use.start < collection.end) continue;
        findings.add(_Finding('A', path, source, use,
            detail: "'$name' is built from l10n and then searched"));
      }
    }
  }
  return findings;
}

class _Finding {
  _Finding(this.id, this.path, this.source, this.match, {this.detail});
  final String id;
  final String path;
  final String source;
  final RegExpMatch match;
  final String? detail;

  int get line => '\n'.allMatches(source.substring(0, match.start)).length + 1;

  String get snippet {
    final start = source.lastIndexOf('\n', match.start) + 1;
    var end = source.indexOf('\n', match.start);
    if (end < 0) end = source.length;
    return source.substring(start, end).trim();
  }

  String get key => '$path::$snippet';

  @override
  String toString() => '[$id] $path:$line  $snippet${detail == null ? '' : '  ($detail)'}';
}

void main() {
  test('no localization trap is present in lib/', () {
    final allowed = _allowlist();
    final findings = _scan();
    final unexpected = findings.where((f) => !allowed.containsKey(f.key)).toList();

    if (unexpected.isNotEmpty) {
      fail('Localization guard: ${unexpected.length} issue(s):\n'
          '${unexpected.map((f) => '  $f').join('\n')}');
    }
  });
}

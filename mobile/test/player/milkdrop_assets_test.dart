import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MilkDrop renderer and presets ship as offline Flutter assets', () async {
    final library = await rootBundle.loadString(
      'assets/milkdrop/butterchurn.min.js',
    );
    final presets = await rootBundle.loadString(
      'assets/milkdrop/butterchurnPresetsMinimal.min.js',
    );
    expect(library, contains('butterchurn'));
    expect(presets, contains('butterchurnPresetsMinimal'));
    expect(library.length, greaterThan(10000));
    expect(presets.length, greaterThan(10000));
  });
}

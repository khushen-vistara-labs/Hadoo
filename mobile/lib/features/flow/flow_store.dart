import 'domain/flow_codec.dart';
import 'domain/flow_models.dart';

/// Small IO boundary, injectable without a database or platform plugin.
class FlowStore {
  FlowStore({required this._read, required this._write});

  static const preferenceKey = 'konnekted.flow.v1';
  final Future<String?> Function() _read;
  final Future<bool> Function(String) _write;
  Future<void> _pending = Future.value();

  Future<FlowData> load() async => FlowCodec.decode(await _read());

  /// Sequential writes prevent a slow old save overwriting a newer Apply.
  /// A failed write is reported to its caller, but does not poison later saves.
  Future<void> save(FlowData data) {
    final text = FlowCodec.encode(data);
    final result = _pending.then((_) async {
      if (text.length > FlowCodec.maxDocumentLength) {
        throw StateError('Flow data is too large to save.');
      }
      if (!await _write(text)) {
        throw StateError('Could not save Flow settings.');
      }
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}

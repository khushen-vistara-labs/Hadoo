import 'package:flutter/material.dart';

import 'lokal_toast.dart';

/// A single, top-centered progress pill; repeated updates replace its text
/// instead of stacking messages above the player's navigation controls.
class LokalStatusSnack {
  LokalStatusSnack(this._context);

  final BuildContext? Function() _context;
  bool _showing = false;

  bool get showing => _showing;

  void update(String message) {
    final context = _context();
    if (context == null) return;
    _showing = true;
    LokalToast.progress(context, message, owner: this);
  }

  void clear() {
    _showing = false;
    LokalToast.dismiss(owner: this);
  }

  void fail(String message) {
    clear();
    final context = _context();
    if (context != null) LokalToast.show(context, message);
  }

  void dispose() => clear();
}

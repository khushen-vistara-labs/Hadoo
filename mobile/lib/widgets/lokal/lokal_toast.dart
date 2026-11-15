import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

/// Global, themed, top-centered in-app notification surface.
///
/// Unlike a ScaffoldMessenger snackbar it never occupies the footer/player
/// area. Transient notifications replace each other in place; long-running
/// operations update a single pill and are removed by their original owner.
class LokalToast {
  LokalToast._();

  static OverlayState? _overlay;
  static OverlayEntry? _entry;
  static Timer? _timer;
  static Object? _owner;
  static final ValueNotifier<_ToastData?> _data = ValueNotifier(null);

  /// Shows a short, non-modal message above the content, below the status bar.
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _present(
      context,
      _ToastData(message: message, actionLabel: actionLabel, onAction: onAction),
      owner: null,
      duration: duration,
    );
  }

  /// Compatibility route for existing SnackBar call sites. Preserve their
  /// content, action and duration while replacing the bottom placement.
  static void fromSnackBar(BuildContext context, SnackBar snack) {
    _present(
      context,
      _ToastData(
        message: '',
        content: snack.content,
        actionLabel: snack.action?.label,
        onAction: snack.action?.onPressed,
      ),
      owner: null,
      duration: snack.duration,
    );
  }

  /// A live status that stays until [dismiss] is called with the same owner.
  static void progress(BuildContext context, String message, {required Object owner}) {
    _present(context, _ToastData(message: message, loading: true),
        owner: owner, duration: null);
  }

  static void _present(
    BuildContext context,
    _ToastData data, {
    required Object? owner,
    required Duration? duration,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _timer?.cancel();
    if (!identical(_overlay, overlay)) {
      _remove();
      _overlay = overlay;
    }
    _owner = owner;
    _data.value = data;
    if (_entry == null) {
      final entry = OverlayEntry(builder: (context) => _ToastHost(data: _data));
      _entry = entry;
      overlay.insert(entry);
    }
    if (duration != null) _timer = Timer(duration, dismiss);
  }

  /// Ignore a stale progress owner's clear; a newer notice is visible instead.
  static void dismiss({Object? owner}) {
    if (owner != null && !identical(_owner, owner)) return;
    _remove();
  }

  static void _remove() {
    _timer?.cancel();
    _timer = null;
    _owner = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    _overlay = null;
    _data.value = null;
  }
}

class _ToastData {
  const _ToastData({
    required this.message,
    this.loading = false,
    this.content,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final bool loading;
  final Widget? content;
  final String? actionLabel;
  final VoidCallback? onAction;
}

class _ToastHost extends StatelessWidget {
  const _ToastHost({required this.data});
  final ValueListenable<_ToastData?> data;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<_ToastData?>(
    valueListenable: data,
    builder: (context, notice, _) {
      if (notice == null) return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      final statusInset = MediaQuery.paddingOf(context).top;
      return Positioned(
        top: statusInset + 12,
        left: 16,
        right: 16,
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(notice.loading ? 'progress' : 'message'),
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 210),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Transform.translate(
              offset: Offset(0, (1 - t) * -12),
              child: Opacity(opacity: t, child: child),
            ),
            child: IgnorePointer(
              ignoring: notice.onAction == null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Material(
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: .34),
                  color: scheme.surface,
                  shape: StadiumBorder(side: BorderSide(
                    color: scheme.onSurface.withValues(alpha: .12),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (notice.loading) ...[
                            SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Flexible(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              child: notice.content ?? Text(notice.message),
                            ),
                          ),
                          if (notice.actionLabel != null && notice.onAction != null) ...[
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                final action = notice.onAction!;
                                LokalToast.dismiss();
                                action();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: scheme.primary,
                                minimumSize: const Size(50, 36),
                              ),
                              child: Text(notice.actionLabel!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/l10n/l10n.dart';

/// Shared Lokal selection/action surface. It uses the current theme rather
/// than a fixed Material popup color, and works with any option value type.
@immutable
class LokalChoice<T> {
  const LokalChoice({
    required this.value,
    required this.label,
    this.icon,
    this.description,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? description;
  final bool destructive;
}

/// Opens a slide-up choice sheet and resolves only after a row was selected.
/// The caller retains responsibility for saving the choice or running actions.
Future<T?> showLokalChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<LokalChoice<T>> choices,
  T? selected,
}) {
  final t = context.lokal;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: t.surface,
    barrierColor: Colors.black.withValues(alpha: t.isLight ? .25 : .5),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: t.border),
    ),
    builder: (sheetContext) {
      final theme = sheetContext.lokal;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                lokalText(title).toUpperCase(),
                style: LokalTheme.label(theme),
              ),
            ),
            Divider(height: 1, color: theme.border),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 6,
                  bottom: 12 + MediaQuery.paddingOf(sheetContext).bottom,
                ),
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  final choice = choices[index];
                  final active = selected != null && choice.value == selected;
                  final ink = choice.destructive
                      ? theme.red
                      : active
                      ? theme.accent
                      : theme.text;
                  return Semantics(
                    button: true,
                    selected: active,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(sheetContext).pop(choice.value);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                choice.icon ?? Icons.tune_rounded,
                                color: choice.destructive
                                    ? theme.red
                                    : active
                                    ? theme.accent
                                    : theme.muted,
                                size: 21,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lokalText(choice.label),
                                      style: TextStyle(
                                        fontFamily: LokalTheme.sans,
                                        color: ink,
                                        fontSize: 15,
                                        fontWeight: active
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    if (choice.description != null)
                                      Text(
                                        lokalText(choice.description!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.muted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (active)
                                Icon(Icons.check_rounded, color: theme.accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

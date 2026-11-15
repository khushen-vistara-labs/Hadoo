import 'package:flick/l10n/l10n.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flutter/material.dart';

/// The card an opt-in online page shows while its source is off: what it
/// does, what it contacts, and one button that turns it on (the same switch
/// as in Settings › Online sources).
class LokalOptInCard extends StatelessWidget {
  const LokalOptInCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTurnOn,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onTurnOn;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.accent, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(message, style: TextStyle(color: t.muted, height: 1.45)),
            const SizedBox(height: 4),
            Text(
              lokalText(
                'You can turn it off again in Settings › Online sources.',
              ),
              style: TextStyle(color: t.muted2, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: t.accent),
              onPressed: onTurnOn,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

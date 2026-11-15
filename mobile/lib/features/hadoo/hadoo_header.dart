import 'package:flutter/material.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/lokal_logo.dart';

/// A terminal prompt with ordinary, accessible music controls.
class HadooHeader extends StatelessWidget {
  const HadooHeader({
    super.key,
    required this.onSearch,
    required this.onDownloads,
    required this.onSettings,
    this.onAppearance,
  });

  final VoidCallback onSearch;
  final VoidCallback onDownloads;
  final VoidCallback onSettings;
  final VoidCallback? onAppearance;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                button: onAppearance != null,
                label: onAppearance == null ? 'Hadoo' : 'Appearance',
                excludeSemantics: true,
                onTap: onAppearance,
                child: GestureDetector(
                  onTap: onAppearance,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.square(
                    dimension: 44,
                    child: Center(child: LokalLogo(size: 40)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'hadoo',
                  style: TextStyle(
                    fontFamily: LokalTheme.mono,
                    color: t.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Semantics(
                label: 'Settings',
                button: true,
                excludeSemantics: true,
                onTap: onSettings,
                child: IconButton(
                  tooltip: 'Settings',
                  onPressed: onSettings,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('YOUR MUSIC. YOUR TERMINAL.', style: LokalTheme.label(t)),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            label: 'Ready to listen',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '> ',
                    style: TextStyle(color: t.accent),
                  ),
                  const TextSpan(text: 'press play'),
                  TextSpan(
                    text: '_',
                    style: TextStyle(color: t.accent),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: LokalTheme.mono,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onSearch,
                icon: Icon(Icons.search, size: 18, color: t.accent),
                label: const Text('/search'),
              ),
              OutlinedButton.icon(
                onPressed: onDownloads,
                icon: Icon(Icons.download_outlined, size: 18, color: t.accent),
                label: const Text('/downloads'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: t.border),
        ],
      ),
    );
  }
}

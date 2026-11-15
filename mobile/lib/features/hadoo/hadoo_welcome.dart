import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/providers/onboarding_provider.dart';
import 'package:flick/widgets/lokal/lokal_logo.dart';

/// Start the requested streaming app without file/folder or desktop setup.
class HadooWelcome extends ConsumerWidget {
  const HadooWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.lokal;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LokalLogo(size: 112),
              const SizedBox(height: 32),
              Text('HADOO', style: LokalTheme.label(t, color: t.accent)),
              const SizedBox(height: 12),
              Text(
                'Infinite music.\nZero noise.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Stream YouTube Music. Save tracks for offline listening. Make the queue yours.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'You can start without an account. Optional sign-in, local files and other connections are in Settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start listening'),
                  onPressed: () =>
                      ref.read(onboardingCompletedProvider.notifier).complete(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const lokalIosUpdateGuideUrl =
    'https://github.com/khushen-vistara-labs/Hadoo/blob/trunk/docs/device-setup.md#iphone';

final iosStoreUrlLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Installation and account credentials stay in the user's chosen store.
class IosStoreUpdateActions extends ConsumerStatefulWidget {
  const IosStoreUpdateActions({super.key});

  @override
  ConsumerState<IosStoreUpdateActions> createState() =>
      _IosStoreUpdateActionsState();
}

class _IosStoreUpdateActionsState extends ConsumerState<IosStoreUpdateActions> {
  String? _message;
  bool _busy = false;

  Future<void> _open(bool sideStore) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final schemes = sideStore
        ? ['sidestore']
        : ['altstore-classic', 'altstore'];
    var opened = false;
    for (final scheme in schemes) {
      final uri = Uri(scheme: scheme, host: '');
      try {
        opened = await ref.read(iosStoreUrlLauncherProvider)(uri);
      } catch (_) {
        opened = false;
      }
      if (opened) break;
    }
    if (!mounted) return;
    final store = sideStore ? 'SideStore' : 'AltStore Classic';
    setState(() {
      _busy = false;
      _message = opened
          ? null
          : '$store could not be opened. See the setup guide for installation steps.';
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'In AltStore Classic, tap My Apps → Refresh All to renew your signature. To install a newer Hadoo build, open its IPA with My Apps → +. Keep the same Apple Account and app identity to retain your library.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton(
            onPressed: _busy ? null : () => _open(false),
            child: const Text('Open AltStore'),
          ),
          FilledButton(
            onPressed: _busy ? null : () => _open(true),
            child: const Text('Open SideStore'),
          ),
        ],
      ),
      TextButton(
        onPressed: () async {
          try {
            if (await ref.read(iosStoreUrlLauncherProvider)(
              Uri.parse(lokalIosUpdateGuideUrl),
            )) {
              return;
            }
          } catch (_) {
            /* Keep the instructions visible on launch failure. */
          }
          if (mounted) {
            setState(
              () => _message =
                  'Could not open the setup guide. Try again when online.',
            );
          }
        },
        child: const Text('Setup guide'),
      ),
      if (_message != null) Text(_message!),
    ],
  );
}

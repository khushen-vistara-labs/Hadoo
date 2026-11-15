import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/providers/listenbrainz_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

/// Self-contained ListenBrainz connect/disconnect row.
class ListenBrainzSettingsTile extends ConsumerStatefulWidget {
  const ListenBrainzSettingsTile({super.key});

  @override
  ConsumerState<ListenBrainzSettingsTile> createState() =>
      _ListenBrainzSettingsTileState();
}

class _ListenBrainzSettingsTileState
    extends ConsumerState<ListenBrainzSettingsTile> {
  Future<void> _showTokenDialog() async {
    final auth = ref.read(listenbrainzAuthServiceProvider);
    final existing = await auth.getSession();

    final tokenController = TextEditingController(text: existing?.token ?? '');

    if (!mounted) return;

    await showLokalSettingsSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TokenInputSheet(
        tokenController: tokenController,
        onConnect: (token) async {
          await auth.connect(token);
          ref.invalidate(listenbrainzSessionProvider);
        },
      ),
    );

    tokenController.dispose();
  }

  Future<void> _disconnect() async {
    final confirmed = await showLokalConfirmSheet(
      context: context,
      useRootNavigator: true,
      title: l10n.disconnectListenbrainz,
      message: l10n.yourListensWillRemainOnListenbrainz,
      confirmLabel: l10n.disconnect,
      cancelLabel: l10n.cancel,
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    final auth = ref.read(listenbrainzAuthServiceProvider);
    await auth.disconnect();
    ref.invalidate(listenbrainzSessionProvider);
  }

  Future<void> _showConnectedBottomSheet(String username) async {
    await showLokalSettingsSheet<void>(
      context: context,
      builder: (ctx) => LokalSheetBody(
        title: l10n.listenbrainzConnected,
        message: l10n.yourMusicIsBeingSubmitted,
        children: [
          LokalSettingsCard(
            color: ctx.lokal.surface2,
            child: LokalSettingRow(
              label: username,
              description: l10n.connectedAccount,
              trailing: const LokalStatusPill(label: 'Connected', active: true),
            ),
          ),
          const SizedBox(height: 16),
          LokalSettingsActionButton(
            label: l10n.editToken,
            icon: Icons.edit_rounded,
            primary: false,
            expand: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showTokenDialog();
            },
          ),
          const SizedBox(height: 10),
          LokalSettingsActionButton(
            label: l10n.disconnect,
            icon: Icons.logout_rounded,
            destructive: true,
            expand: true,
            onPressed: () {
              Navigator.pop(ctx);
              _disconnect();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(listenbrainzSessionProvider);
    final t = context.lokal;

    return sessionAsync.when(
      loading: () => LokalSettingRow(
        label: l10n.listenbrainz,
        description: l10n.loadingSession,
      ),
      error: (error, stackTrace) => LokalSettingRow(
        label: l10n.listenbrainz,
        description: l10n.couldNotLoadSession,
        onTap: _showTokenDialog,
        trailing: Icon(Icons.chevron_right_rounded, size: 22, color: t.muted),
      ),
      data: (session) {
        if (session != null) {
          return LokalSettingRow(
            label: l10n.listenbrainz,
            description: l10n.connectedAs(session.username),
            onTap: () => _showConnectedBottomSheet(session.username),
            trailing: const LokalStatusPill(label: 'Connected', active: true),
          );
        }
        return LokalSettingRow(
          label: l10n.listenbrainz,
          description: l10n.connectToSubmitYourListeningHistory,
          onTap: _showTokenDialog,
          trailing: LokalSettingButton(
            label: l10n.connect,
            onPressed: _showTokenDialog,
          ),
        );
      },
    );
  }
}

/// Internal bottom sheet for entering and validating a ListenBrainz token.
class _TokenInputSheet extends StatefulWidget {
  const _TokenInputSheet({
    required this.tokenController,
    required this.onConnect,
  });

  final TextEditingController tokenController;
  final Future<void> Function(String token) onConnect;

  @override
  State<_TokenInputSheet> createState() => _TokenInputSheetState();
}

class _TokenInputSheetState extends State<_TokenInputSheet> {
  bool _isConnecting = false;
  bool _obscureToken = true;
  String? _errorMessage;

  Future<void> _connect() async {
    final token = widget.tokenController.text.trim();

    if (token.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseEnterYourListenbrainzUserToken);
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConnect(token);
      if (mounted) {
        Navigator.of(context).pop();
        LokalToast.fromSnackBar(context, 
          SnackBar(
            content: Text(l10n.listenbrainzConnected2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message =
            RegExp('SocketException|Failed host lookup').hasMatch('$e')
            ? l10n.noInternetConnectionPleaseCheckYour
            : l10n.couldNotConnectToListenbrainzCheck;
        setState(() {
          _isConnecting = false;
          _errorMessage = message;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    final uri = Uri.parse('https://listenbrainz.org/settings/');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        LokalToast.fromSnackBar(context, 
          SnackBar(
            content: Text(l10n.couldNotOpenBrowser),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        LokalToast.fromSnackBar(context, 
          SnackBar(
            content: Text(l10n.couldNotOpenLink2(e)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: LokalSheetBody(
          title: l10n.connectListenbrainz,
          message: l10n.copyYourUserTokenFromListenbrainz,
          children: [
            LokalSettingsCard(
              color: t.surface2,
              child: LokalSettingRow(
                label: l10n.openListenbrainzOrgSettings,
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: t.muted,
                ),
                onTap: _openSettings,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: widget.tokenController,
              obscureText: _obscureToken,
              autocorrect: false,
              enableSuggestions: false,
              style: TextStyle(color: t.text),
              decoration: lokalInputDecoration(
                context,
                label: l10n.userToken,
                hint: l10n.pasteYourListenbrainzToken,
                errorText: _errorMessage,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureToken
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: t.muted,
                  ),
                  onPressed: () {
                    setState(() => _obscureToken = !_obscureToken);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            LokalSettingsActionButton(
              label: _isConnecting ? '${l10n.connect}…' : l10n.connect,
              expand: true,
              onPressed: _isConnecting ? null : _connect,
            ),
          ],
        ),
      ),
    );
  }
}

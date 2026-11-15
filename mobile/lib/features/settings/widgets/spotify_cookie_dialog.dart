import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/l10n/l10n.dart';

/// Keep a failed connection editable rather than losing the pasted cookie.
class SpotifyCookieDialog extends StatefulWidget {
  const SpotifyCookieDialog({
    super.key,
    required this.onConnect,
    required this.onCancel,
  });
  final Future<void> Function(String) onConnect;
  final Future<void> Function() onCancel;
  @override
  State<SpotifyCookieDialog> createState() => _SpotifyCookieDialogState();
}

class _SpotifyCookieDialogState extends State<SpotifyCookieDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConnect(_controller.text);
      if (!mounted) return;
      setState(() => _busy = false);
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = lokalText(
          error is SpotifyOAuthException
              ? error.message
              : 'Spotify connection failed. Check your network and try again.',
        );
      });
    }
  }

  void _cancel() {
    unawaited(widget.onCancel().catchError((Object _) {}));
    setState(() => _busy = false);
    Navigator.pop(context, false);
  }

  @override
  void dispose() {
    if (_busy) unawaited(widget.onCancel().catchError((Object _) {}));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text(lokalText('Connect Spotify')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lokalText(
                'Paste the sp_dc session cookie from your signed-in Spotify web session. It is stored encrypted on this device.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => unawaited(_submit()),
              decoration: InputDecoration(
                labelText: lokalText('Spotify sp_dc cookie'),
                errorText: _error,
                errorMaxLines: 5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: Text(lokalText('Cancel'))),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(lokalText('Connect')),
        ),
      ],
    ),
  );
}

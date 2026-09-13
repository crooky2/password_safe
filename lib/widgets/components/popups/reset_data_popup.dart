import "package:cryptography/cryptography.dart";
import "package:flutter/material.dart";

import "../../../l10n/app_localizations.dart";
import "../../screen_popup.dart";
import "../../secret_text_field.dart";

class ResetDataPopup extends StatefulWidget {
  const ResetDataPopup({super.key, required this.onReset});

  final Future<void> Function(String masterPassword) onReset;

  @override
  State<ResetDataPopup> createState() => _ResetDataPopupState();
}

class _ResetDataPopupState extends State<ResetDataPopup> {
  final TextEditingController _passwordController = TextEditingController();

  bool _busy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "enterCurrentPassword"; //TODO: localization
      });
      return;
    }

    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      await widget.onReset(password);

      if (!mounted) {
        return;
      }

      _passwordController.clear();
      Navigator.of(context).pop();
    } on SecretBoxAuthenticationError {
      //TODO: localization
      _showError("invalidPassword");
    } on StateError {
      _showError("resetDataUnavailable");
    } catch (_) {
      _showError("resetDataFailed");
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
    });
  }

  void _cancel() {
    if (!_busy) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return PopScope<void>(
      canPop: !_busy,
      child: ScreenPopup(
        title: "resetAppData", //TODO: localization
        subtitle: "resetAppDataSubtitle",
        onClose: _busy ? null : _cancel,
        children: [
          SecretTextField(
            controller: _passwordController,
            labelText: l10n!.password,
            enabled: !_busy,
            enableBorder: true,
            onSubmitted: (_) {
              _submit();
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _errorMessage!,
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: _busy ? null : _cancel,
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_forever_rounded),
                  label: Text(_busy ? "resetDataWorking" : l10n.resetAppData), //TODO: localization
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import "package:cryptography/cryptography.dart";
import "package:flutter/material.dart";

import "../../../l10n/app_localizations.dart";
import "../../screen_popup.dart";
import "../../secret_text_field.dart";

enum _ResetDataError { passwordRequired, invalidPassword, unavailable, failed }

class ResetDataPopup extends StatefulWidget {
  const ResetDataPopup({super.key, required this.onReset});

  final Future<void> Function(String masterPassword) onReset;

  @override
  State<ResetDataPopup> createState() => _ResetDataPopupState();
}

class _ResetDataPopupState extends State<ResetDataPopup> {
  final TextEditingController _passwordController = TextEditingController();

  bool _busy = false;
  _ResetDataError? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }

    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _error = _ResetDataError.passwordRequired;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await widget.onReset(password);

      if (!mounted) {
        return;
      }

      _passwordController.clear();
      Navigator.of(context).pop();
    } on SecretBoxAuthenticationError {
      _showError(_ResetDataError.invalidPassword);
    } on StateError {
      _showError(_ResetDataError.unavailable);
    } catch (_) {
      _showError(_ResetDataError.failed);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showError(_ResetDataError error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _error = error;
    });
  }

  void _cancel() {
    if (!_busy) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final errorMessage = switch (_error) {
      _ResetDataError.passwordRequired => l10n.enterCurrentPassword,
      _ResetDataError.invalidPassword => l10n.authWrongPassword,
      _ResetDataError.unavailable => l10n.resetDataUnavailable,
      _ResetDataError.failed => l10n.resetDataFailed,
      null => null,
    };

    return PopScope<void>(
      canPop: !_busy,
      child: ScreenPopup(
        title: l10n.resetAppData,
        onClose: _busy ? null : _cancel,
        children: [
          !_busy
              ? SecretTextField(
                  controller: _passwordController,
                  labelText: l10n.password,
                  enabled: !_busy,
                  enableBorder: true,
                  onSubmitted: (_) {
                    _submit();
                  },
                )
              : const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                ),

          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(errorMessage, style: TextStyle(color: colors.error)),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: _busy,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: _busy
                        ? FilledButton.styleFrom(
                            backgroundColor: colors.surfaceContainerHighest,
                            foregroundColor: colors.onSurfaceVariant,
                          )
                        : FilledButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: colors.onError,
                          ),
                    child: Text(l10n.resetAppData),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _busy ? null : _cancel,
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

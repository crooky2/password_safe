import 'package:flutter/material.dart';
import "package:flutter/services.dart";

import "dart:async";

import '../widgets/screen_frame.dart';
import "../widgets/secret_text_field.dart";
import "../auth/auth_controller.dart";
import "../l10n/app_localizations.dart";
import "../l10n/localized_messages.dart";

enum UnlockMode { masterPassword, pin, fingerprint }

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlock,
    required this.onUnlockWithPin,
    required this.onUnlockWithFingerprint,
    required this.isPinUnlockEnabled,
    required this.isFingerprintUnlockEnabled,
    required this.refreshUnlockBlock,
    this.unlockBlockedUntil,
    this.unlockBlockedRequiresMasterPassword = false,
    this.autoPromptFingerprint = false,
    this.errorMessage,
  });

  final Future<bool> Function(String) onUnlock;
  final Future<bool> Function(String) onUnlockWithPin;
  final Future<bool> Function({required String promptTitle})
  onUnlockWithFingerprint;
  final Future<bool> Function() isPinUnlockEnabled;
  final Future<bool> Function() isFingerprintUnlockEnabled;
  final Future<void> Function() refreshUnlockBlock;
  final DateTime? unlockBlockedUntil;
  final bool unlockBlockedRequiresMasterPassword;
  final bool autoPromptFingerprint;
  final AuthFeedbackMessage? errorMessage;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isCheckingQuickUnlock = true;
  bool _pinUnlockAvailable = false;
  bool _fingerprintUnlockAvailable = false;
  bool _didAutoPromptFingerprint = false;
  bool _isSubmitting = false;
  bool _isFingerprintPromptQueued = false;
  UnlockMode _unlockMode = UnlockMode.masterPassword;
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadQuickUnlockMode();
    _syncCountdownTimer();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.unlockBlockedRequiresMasterPassword &&
        _unlockMode != UnlockMode.masterPassword) {
      _unlockMode = UnlockMode.masterPassword;
      _passwordController.clear();
    }

    _syncCountdownTimer();

    if (!oldWidget.autoPromptFingerprint &&
        widget.autoPromptFingerprint &&
        _fingerprintUnlockAvailable &&
        _unlockMode == UnlockMode.fingerprint) {
      _promptFingerprintAfterFrame();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isCurrentUnlockModeBlocked) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final l10n = AppLocalizations.of(context)!;

    var success = false;

    try {
      success = switch (_unlockMode) {
        UnlockMode.fingerprint => await widget.onUnlockWithFingerprint(
          promptTitle: l10n.confirmDeviceAuthForQuickUnlock,
        ),
        UnlockMode.pin =>
          _passwordController.text.trim().isEmpty
              ? false
              : await widget.onUnlockWithPin(_passwordController.text),
        UnlockMode.masterPassword =>
          _passwordController.text.trim().isEmpty
              ? false
              : await widget.onUnlock(_passwordController.text),
      };
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (!success) {
      _passwordController.clear();
    }
  }

  Future<void> _loadQuickUnlockMode() async {
    await widget.refreshUnlockBlock();

    final pinEnabled = await widget.isPinUnlockEnabled();
    final fingerprintEnabled = await widget.isFingerprintUnlockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _pinUnlockAvailable = pinEnabled;
      _fingerprintUnlockAvailable = fingerprintEnabled;
      _unlockMode = fingerprintEnabled
          ? UnlockMode.fingerprint
          : pinEnabled
          ? UnlockMode.pin
          : UnlockMode.masterPassword;
      _isCheckingQuickUnlock = false;
    });

    if (fingerprintEnabled && widget.autoPromptFingerprint) {
      _promptFingerprintAfterFrame();
    }
  }

  Duration get _remainingUnlockBlock {
    final until = widget.unlockBlockedUntil;

    if (until == null) {
      return Duration.zero;
    }

    final remaining = until.difference(_now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get _isCurrentUnlockModeBlocked {
    final remaining = _remainingUnlockBlock;

    if (remaining <= Duration.zero) {
      return false;
    }

    if (widget.unlockBlockedRequiresMasterPassword) {
      return true;
    }

    return _unlockMode == UnlockMode.pin;
  }

  String _formatCountdown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes > 0) {
      return "$minutes:${seconds.toString().padLeft(2, "0")}";
    }

    return "${seconds}s";
  }

  void _syncCountdownTimer() {
    final hasCountdown =
        widget.unlockBlockedUntil?.isAfter(DateTime.now()) ?? false;

    if (!hasCountdown) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      return;
    }

    _countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) {
        return;
      }

      setState(() {
        _now = DateTime.now();
      });

      if (_remainingUnlockBlock <= Duration.zero) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        await widget.refreshUnlockBlock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingQuickUnlock) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;
    final unlockLabel = switch (_unlockMode) {
      UnlockMode.masterPassword => l10n.password,
      UnlockMode.pin => l10n.pin,
      UnlockMode.fingerprint => l10n.fingerprint,
    };

    final unlockHint = switch (_unlockMode) {
      UnlockMode.masterPassword => l10n.enterYourPassword,
      UnlockMode.pin => l10n.enterYourPin,
      UnlockMode.fingerprint => l10n.enterFingerprintToUnlock,
    };

    final remaining = _remainingUnlockBlock;
    final isBlocked = _isCurrentUnlockModeBlocked;
    final isUnlockButtonDisabled =
        isBlocked || _isSubmitting || _isFingerprintPromptQueued;

    final countdownMessage = remaining > Duration.zero
        ? widget.unlockBlockedRequiresMasterPassword
              ? l10n.lockScreenTooManyPinAttemptsMasterAvailable(
                  _formatCountdown(remaining),
                )
              : _unlockMode == UnlockMode.pin
              ? l10n.lockScreenWrongPinTryAgainUseMasterPassword(
                  _formatCountdown(remaining),
                )
              : l10n.lockScreenQuickUnlockDisabledFor(
                  _formatCountdown(remaining),
                )
        : null;

    final visibleErrorMessage =
        countdownMessage ??
        (widget.errorMessage == null
            ? null
            : l10n.authFeedback(widget.errorMessage!));

    return ScreenFrame(
      title: l10n.appLocked,
      subtitle: switch (_unlockMode) {
        UnlockMode.pin => l10n.enterPinToUnlock,
        UnlockMode.fingerprint => l10n.enterFingerprintToUnlock,
        UnlockMode.masterPassword => l10n.enterPasswordToUnlock,
      },
      icon: Icons.lock_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_unlockMode != UnlockMode.fingerprint)
                SecretTextField(
                  controller: _passwordController,
                  labelText: unlockLabel,
                  hintText: unlockHint,
                  enableBorder: true,
                  enabled: !isBlocked,
                  keyboardType: _unlockMode == UnlockMode.pin
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: _unlockMode == UnlockMode.pin
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  onSubmitted: isBlocked ? null : (_) => _submit(),
                ),
              if (visibleErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    visibleErrorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: isUnlockButtonDisabled
              ? null
              : _unlockMode == UnlockMode.fingerprint
              ? _requestFingerprintPrompt
              : _submit,
          icon: const Icon(Icons.lock_open_rounded),
          label: Text(l10n.unlock),
        ),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (_unlockMode != UnlockMode.masterPassword)
              TextButton(
                onPressed: () => _setUnlockMode(UnlockMode.masterPassword),
                child: Text(l10n.useMasterPassword),
              ),
            if (_pinUnlockAvailable && _unlockMode != UnlockMode.pin)
              TextButton(
                onPressed: widget.unlockBlockedRequiresMasterPassword
                    ? null
                    : () => _setUnlockMode(UnlockMode.pin),
                child: Text(l10n.usePin),
              ),
            if (_fingerprintUnlockAvailable &&
                _unlockMode != UnlockMode.fingerprint)
              TextButton(
                onPressed: widget.unlockBlockedRequiresMasterPassword
                    ? null
                    : () => _setUnlockMode(UnlockMode.fingerprint),
                child: Text(l10n.useFingerprint),
              ),
          ],
        ),
      ],
    );
  }

  void _setUnlockMode(UnlockMode mode) {
    setState(() {
      _unlockMode = mode;
      _passwordController.clear();
    });

    if (mode == UnlockMode.fingerprint) {
      _requestFingerprintPrompt();
    }
  }

  void _promptFingerprintAfterFrame() {
    if (_didAutoPromptFingerprint) {
      return;
    }

    _didAutoPromptFingerprint = true;
    _requestFingerprintPrompt();
  }

  void _requestFingerprintPrompt() {
    if (_isSubmitting || _isFingerprintPromptQueued) {
      return;
    }

    setState(() {
      _isFingerprintPromptQueued = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      if (!mounted) {
        return;
      }

      setState(() {
        _isFingerprintPromptQueued = false;
      });

      if (_unlockMode != UnlockMode.fingerprint ||
          _isCurrentUnlockModeBlocked) {
        return;
      }

      await _submit();
    });
  }
}

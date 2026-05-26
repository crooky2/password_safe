import 'package:flutter/material.dart';
import "package:flutter/services.dart";

import "dart:async";

import '../widgets/screen_frame.dart';
import "../widgets/secret_text_field.dart";

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlock,
    required this.onUnlockWithPin,
    required this.isQuickUnlockEnabled,
    required this.refreshUnlockBlock,
    this.unlockBlockedUntil,
    this.unlockBlockedRequiresMasterPassword = false,
    this.errorMessage,
  });

  final Future<bool> Function(String) onUnlock;
  final Future<bool> Function(String) onUnlockWithPin;
  final Future<bool> Function() isQuickUnlockEnabled;
  final Future<void> Function() refreshUnlockBlock;
  final DateTime? unlockBlockedUntil;
  final bool unlockBlockedRequiresMasterPassword;
  final String? errorMessage;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isCheckingQuickUnlock = true;
  bool _quickUnlockAvailable = false;
  bool _usePinUnlock = false;
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

    if (widget.unlockBlockedRequiresMasterPassword && _usePinUnlock) {
      _usePinUnlock = false;
      _quickUnlockAvailable = false;
      _passwordController.clear();
    }

    _syncCountdownTimer();
  }

  Future<void> _submit() async {
    if (_isCurrentUnlockModeBlocked) {
      return;
    }

    final password = _passwordController.text;

    if (password.trim().isEmpty) {
      return;
    }

    final success = _usePinUnlock
        ? await widget.onUnlockWithPin(password)
        : await widget.onUnlock(password);

    if (!mounted) {
      return;
    }

    if (!success) {
      _passwordController.clear();
    }
  }

  Future<void> _loadQuickUnlockMode() async {
    await widget.refreshUnlockBlock();
    final enabled = await widget.isQuickUnlockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _quickUnlockAvailable = enabled;
      _usePinUnlock = enabled;
      _isCheckingQuickUnlock = false;
    });
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

    return _usePinUnlock;
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

    final unlockLabel = _usePinUnlock ? "PIN" : "Password";
    final unlockHint = _usePinUnlock ? "Enter your PIN" : "Enter your password";

    final remaining = _remainingUnlockBlock;
    final isBlocked = _isCurrentUnlockModeBlocked;

    final countdownMessage = remaining > Duration.zero
        ? widget.unlockBlockedRequiresMasterPassword
              ? "Too many PIN attempts. Master password unlock is available in ${_formatCountdown(remaining)}."
              : _usePinUnlock
              ? "Wrong PIN. Try again in ${_formatCountdown(remaining)} or use master password."
              : "Quick unlock is disabled down for ${_formatCountdown(remaining)}."
        : null;

    final visibleErrorMessage = countdownMessage ?? widget.errorMessage;

    return ScreenFrame(
      title: 'App Locked',
      subtitle: _usePinUnlock
          ? "Enter your PIN to unlock."
          : "Enter your password to unlock.",
      icon: Icons.lock_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SecretTextField(
                controller: _passwordController,
                labelText: unlockLabel,
                hintText: unlockHint,
                enableBorder: true,
                enabled: !isBlocked,
                keyboardType: _usePinUnlock
                    ? TextInputType.number
                    : TextInputType.text,

                inputFormatters: _usePinUnlock
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
          onPressed: isBlocked ? null : _submit,
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Unlock'),
        ),

        if (_usePinUnlock)
          TextButton(
            onPressed: () {
              setState(() {
                _usePinUnlock = false;
                _passwordController.clear();
              });
            },
            child: const Text("Use master password"),
          )
        else if (_quickUnlockAvailable)
          TextButton(
            onPressed: () {
              setState(() {
                _usePinUnlock = true;
                _passwordController.clear();
              });
            },
            child: const Text("Use quick unlock"),
          ),
      ],
    );
  }
}

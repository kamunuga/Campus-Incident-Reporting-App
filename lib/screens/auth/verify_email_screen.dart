import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/auth/auth_layout.dart';
import 'package:campusfix/widgets/app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _cooldownSeconds = 30;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = 0;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) context.read<SessionProvider>().checkVerification();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final verified = await context.read<SessionProvider>().checkVerification();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!verified) {
      AppSnack.info(context, 'Not verified yet. Open the link in your email.');
    }
  }

  Future<void> _resend() async {
    final session = context.read<SessionProvider>();
    final ok = await session.resendVerification();
    if (!mounted) return;
    if (ok) {
      AppSnack.success(context, 'Verification email sent again.');
      _startCooldown();
    } else {
      AppSnack.error(context, session.error ?? 'Could not send email.');
    }
  }

  void _startCooldown() {
    setState(() => _cooldown = _cooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final email = session.pendingEmail ?? 'your ALU email';

    return AuthLayout(
      title: 'Verify your email',
      subtitle: 'We sent a verification link to $email. '
          'Open it to confirm your ALU account, then come back here.',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.matchaMist,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.mark_email_unread_outlined, color: AppColors.matcha),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This page refreshes automatically once your email is verified. '
                  'Check your spam folder if you cannot find the message.',
                  style: TextStyle(color: AppColors.matchaDeep, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'I have verified my email',
          icon: Icons.verified_outlined,
          isLoading: _checking,
          onPressed: _checkNow,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: _cooldown > 0
              ? 'Resend email in ${_cooldown}s'
              : 'Resend verification email',
          variant: AppButtonVariant.outlined,
          isLoading: session.isBusy,
          onPressed: _cooldown > 0 ? null : _resend,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Use a different account',
          variant: AppButtonVariant.text,
          onPressed: session.signOut,
        ),
      ],
    );
  }
}

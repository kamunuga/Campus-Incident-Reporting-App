import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/auth/login_screen.dart';
import 'package:campusfix/screens/auth/verify_email_screen.dart';
import 'package:campusfix/screens/home/home_shell.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/brand_mark.dart';
import 'package:campusfix/widgets/common.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<SessionProvider, SessionStatus>(
      (session) => session.status,
    );

    final Widget child = switch (status) {
      SessionStatus.loading => const _SplashView(),
      SessionStatus.signedOut => const LoginScreen(),
      SessionStatus.unverified => const VerifyEmailScreen(),
      SessionStatus.ready => const HomeShell(),
      SessionStatus.error => const _SessionErrorView(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(status), child: child),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: 64),
            SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionErrorView extends StatelessWidget {
  const _SessionErrorView();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Something went wrong',
                  message: session.error ?? 'Please try again.',
                ),
              ),
              AppButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: session.retry,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.outlined,
                onPressed: session.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

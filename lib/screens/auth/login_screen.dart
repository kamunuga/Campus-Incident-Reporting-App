import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/core/utils/validators.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/auth/auth_layout.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionProvider>();
    final ok = await session.signIn(_email.text, _password.text);
    if (!ok && mounted) {
      AppSnack.error(context, session.error ?? 'Sign in failed.');
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final formKey = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We will email you a link to choose a new password.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller,
                label: 'ALU email',
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || !mounted) return;

    final session = context.read<SessionProvider>();
    final ok = await session.sendPasswordReset(email);
    if (!mounted) return;
    if (ok) {
      AppSnack.success(context, 'Reset link sent to $email');
    } else {
      AppSnack.error(context, session.error ?? 'Could not send reset link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionProvider, bool>((s) => s.isBusy);

    return AuthLayout(
      title: 'Welcome back',
      subtitle:
          'Sign in with your ALU account to report campus issues and follow their progress.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _email,
                  label: 'ALU email',
                  hint: 'name@alustudent.com',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.loginPassword,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: busy ? null : _forgotPassword,
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Sign in',
          icon: Icons.login,
          isLoading: busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'New to CampusFix?',
              style: TextStyle(color: AppColors.inkMuted),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.of(context).pushNamed(AppRoutes.register),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/core/utils/validators.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/auth/auth_layout.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionProvider>();
    final navigator = Navigator.of(context);
    final ok = await session.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      AppSnack.success(context, 'Account created. Check your inbox to verify.');
      navigator.popUntil((route) => route.isFirst);
    } else {
      AppSnack.error(context, session.error ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionProvider, bool>((s) => s.isBusy);

    return AuthLayout(
      showBack: true,
      title: 'Create your account',
      subtitle:
          'Only ALU emails can join. We will send a verification link before you can start reporting.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _name,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
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
                  hint: 'At least 8 characters with a number',
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirm,
                  label: 'Confirm password',
                  icon: Icons.lock_reset_outlined,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(() => _password.text),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Create account',
          icon: Icons.person_add_alt,
          isLoading: busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        const Text(
          'Campus staff accounts are activated by an administrator after sign up.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.inkMuted, fontSize: 12.5),
        ),
      ],
    );
  }
}

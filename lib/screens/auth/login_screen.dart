import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/auth.dart';
import '../../router.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/Login.dc.html.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// After signing in: the main shell if this device has a profile,
  /// otherwise the consent page / setup wizard (the wizard requires KVKK
  /// consent, F20).
  void _routeNext(AppState state) {
    final next = state.setupComplete
        ? AppRoutes.main
        : state.hasConsent
            ? AppRoutes.setupGender
            : AppRoutes.healthConsent;
    Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = context.read<AppState>();
    // Builds without Supabase configured stay local-only, as before.
    if (!state.accountsAvailable) return _routeNext(state);

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await state.signIn(
          email: _emailController.text, password: _passwordController.text);
    } on AuthFailure catch (f) {
      if (mounted) setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(f.message)));
      return;
    }
    if (!mounted) return;
    // Cloud backup is opt-in; accepting also pulls this account's profile,
    // so a second device lands straight in the app.
    if (!state.hasCloudConsent) {
      await Navigator.of(context).push(AppRoutes.pushCloudConsent());
      if (!mounted) return;
    }
    _routeNext(state);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).maybePop()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tekrar hoş geldin', style: textTheme.headlineLarge?.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'Kaldığın yerden devam etmek için giriş yap.',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-posta', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'E-posta gerekli' : null,
                      ),
                      const SizedBox(height: 24),
                      Text('Şifre', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty) ? 'Şifre gerekli' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                              AppRoutes.pushForgotPassword(
                                  initialEmail: _emailController.text.trim())),
                          child: const Text('Şifremi unuttum'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _submit,
                          child: const Text('Giriş yap'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('veya', style: textTheme.bodyMedium),
                          ),
                          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const _GoogleGlyph(),
                          label: const Text('Google ile devam et'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    children: [
                      const TextSpan(text: 'Hesabın yok mu? '),
                      TextSpan(
                        text: 'Kayıt ol',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: Text('G', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

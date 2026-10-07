import 'package:flutter/material.dart';

import '../../data/app_state.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // There's no real backend to authenticate against — if this device
      // never finished setup there's nothing to "log back into", so route
      // there instead of a blank main shell.
      // The wizard also requires KVKK consent (F20) first.
      final state = AppState.instance;
      final next = state.setupComplete
          ? AppRoutes.main
          : state.hasConsent
              ? AppRoutes.setupGender
              : AppRoutes.healthConsent;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
    }
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
                          onPressed: () {},
                          child: const Text('Şifremi unuttum'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
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

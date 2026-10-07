import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/SignUp.dc.html.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final draft = AppState.instance.draft;
      draft.name = _nameController.text.trim();
      draft.email = _emailController.text.trim();
      Navigator.of(context).pushNamed(AppRoutes.healthConsent);
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
                  Text('Hesap oluştur', style: textTheme.headlineLarge?.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'Hedeflerine ulaşmak için ilk adımı at. Kayıt ücretsiz.',
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
                      Text('Ad Soyad', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Ad Soyad gerekli' : null,
                      ),
                      const SizedBox(height: 24),
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
                          hintText: 'Şifreni oluştur',
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
                            (value == null || value.length < 8) ? 'En az 8 karakter girin' : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'En az 8 karakter, bir rakam içermeli',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Kayıt ol'),
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
              child: Column(
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                        children: [
                          const TextSpan(text: 'Zaten hesabın var mı? '),
                          TextSpan(
                            text: 'Giriş yap',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Devam ederek Kullanım Koşulları ve Gizlilik Politikası'nı kabul etmiş olursun.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.5),
                  ),
                ],
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

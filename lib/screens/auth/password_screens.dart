import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/auth.dart';
import '../../data/profile_validation.dart' show validateEmail;
import '../../widgets/form_parts.dart';

/// "Şifremi unuttum": e-mails a reset link that reopens the app on the
/// "new password" screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await context.read<AppState>().sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FormScreenHeader('Şifremi unuttum'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: _sent
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.mark_email_read_rounded,
                              size: 56,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text('E-postanı kontrol et',
                              style: textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            '${_email.text.trim()} adresine bir şifre sıfırlama '
                            'bağlantısı gönderdik. Bağlantıyı bu telefonda aç; '
                            'Denge yeni şifreni belirlemen için açılacak.',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesabının e-posta adresini yaz, sana şifreni '
                              'sıfırlaman için bir bağlantı gönderelim.',
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            LabeledTextField(
                              label: 'E-posta',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v.trim().isEmpty
                                  ? 'E-posta gerekli'
                                  : validateEmail(v),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _sent
                  ? OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56)),
                      child: const Text('Giriş ekranına dön'),
                    )
                  : ElevatedButton(
                      onPressed: _busy ? null : _send,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56)),
                      child: const Text('Bağlantı gönder'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opened by the app root when a password-reset link brings the user back
/// (Supabase has already started a recovery session).
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await context.read<AppState>().updatePassword(_password.text);
    } on AuthFailure catch (f) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
      return;
    }
    messenger.showSnackBar(
        const SnackBar(content: Text('Şifren güncellendi')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FormScreenHeader('Yeni şifre'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _PasswordField(
                        label: 'Yeni şifre',
                        controller: _password,
                        validator: validatePassword,
                      ),
                      _PasswordField(
                        label: 'Yeni şifre (tekrar)',
                        controller: _repeat,
                        validator: (v) =>
                            v == _password.text ? null : 'Şifreler aynı değil',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton(
                onPressed: _busy ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56)),
                child: const Text('Şifreyi kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String) validator;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => widget.validator(v ?? ''),
          ),
        ],
      ),
    );
  }
}

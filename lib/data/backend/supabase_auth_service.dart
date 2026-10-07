import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../auth.dart';

/// Deep link the confirmation and password-reset e-mails point to; must be
/// listed under Authentication → URL Configuration → Redirect URLs in the
/// Supabase dashboard, and is registered in AndroidManifest / Info.plist.
const authRedirectUrl = 'com.denge.denge://login-callback';

/// Supabase project settings, passed with `--dart-define-from-file`
/// (CLAUDE.md §13.1). Both empty means "no cloud": the app stays local.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

/// Maps whatever Supabase throws to an [AuthFailure].
AuthFailure mapAuthError(Object error) {
  if (error is AuthFailure) return error;
  if (error is sb.AuthRetryableFetchException) {
    return const AuthFailure(AuthFailureCode.network);
  }
  if (error is sb.AuthWeakPasswordException) {
    return const AuthFailure(AuthFailureCode.weakPassword);
  }
  if (error is sb.AuthException) {
    return AuthFailure(switch (error.code) {
      'invalid_credentials' => AuthFailureCode.invalidCredentials,
      'user_already_exists' || 'email_exists' => AuthFailureCode.emailTaken,
      'email_not_confirmed' => AuthFailureCode.emailNotConfirmed,
      'weak_password' => AuthFailureCode.weakPassword,
      'same_password' => AuthFailureCode.samePassword,
      'validation_failed' || 'email_address_invalid' =>
        AuthFailureCode.invalidEmail,
      'over_email_send_rate_limit' ||
      'over_request_rate_limit' ||
      'over_sms_send_rate_limit' =>
        AuthFailureCode.rateLimited,
      _ => AuthFailureCode.unknown,
    });
  }
  return const AuthFailure(AuthFailureCode.unknown);
}

/// [AuthService] backed by Supabase Auth (e-mail + password). Sessions are
/// persisted and refreshed by `supabase_flutter` itself.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._auth);

  /// Initialises Supabase; call once from `main` when
  /// [SupabaseConfig.isConfigured].
  static Future<SupabaseAuthService> initialize() async {
    final supabase = await sb.Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    return SupabaseAuthService(supabase.client.auth);
  }

  final sb.GoTrueClient _auth;

  @override
  bool get isAvailable => true;

  static AuthUser _toUser(sb.User u) => AuthUser(
        id: u.id,
        email: u.email ?? '',
        name: (u.userMetadata?['name'] as String?) ?? '',
      );

  @override
  AuthUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _toUser(u);
  }

  @override
  Stream<AuthEvent> get events => _auth.onAuthStateChange
      .map((s) => switch (s.event) {
            sb.AuthChangeEvent.signedIn => AuthEvent.signedIn,
            sb.AuthChangeEvent.signedOut => AuthEvent.signedOut,
            sb.AuthChangeEvent.passwordRecovery => AuthEvent.passwordRecovery,
            _ => null,
          })
      .where((e) => e != null)
      .cast<AuthEvent>()
      // A refresh failure surfaces as a stream error; the session simply
      // ends, which signedOut already covers.
      .handleError((Object _) {});

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _guard(() async {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: authRedirectUrl,
      );
      // With confirmation on, Supabase answers an existing address with a
      // user that has no identities instead of an error (anti-enumeration).
      final identities = res.user?.identities;
      if (res.session == null && identities != null && identities.isEmpty) {
        throw const AuthFailure(AuthFailureCode.emailTaken);
      }
      return res.session == null
          ? SignUpResult.needsEmailConfirmation
          : SignUpResult.signedIn;
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Signing out locally must always succeed, even offline.
    }
  }

  @override
  Future<void> sendPasswordReset(String email) => _guard(
      () => _auth.resetPasswordForEmail(email, redirectTo: authRedirectUrl));

  @override
  Future<void> updatePassword(String newPassword) => _guard(
      () => _auth.updateUser(sb.UserAttributes(password: newPassword)));
}

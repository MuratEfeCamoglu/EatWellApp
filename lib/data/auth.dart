/// Account system as the app sees it, independent of the cloud provider
/// (Supabase lives behind this in `backend/`, CLAUDE.md §13.1).
library;

/// The signed-in account.
class AuthUser {
  const AuthUser({required this.id, required this.email, this.name = ''});

  final String id;
  final String email;

  /// Name given at sign-up (account metadata); may be empty.
  final String name;
}

enum AuthEvent { signedIn, signedOut, passwordRecovery }

enum SignUpResult {
  /// The account exists and a session is open.
  signedIn,

  /// The project requires e-mail confirmation; the user must tap the link
  /// we sent before they can sign in.
  needsEmailConfirmation,
}

enum AuthFailureCode {
  invalidCredentials,
  emailTaken,
  emailNotConfirmed,
  weakPassword,
  samePassword,
  invalidEmail,
  rateLimited,
  network,
  unavailable,
  unknown,
}

/// A failed account operation with a Turkish message for the user.
class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;

  String get message => switch (code) {
        AuthFailureCode.invalidCredentials => 'E-posta veya şifre hatalı.',
        AuthFailureCode.emailTaken =>
          'Bu e-posta ile zaten bir hesap var. Giriş yapmayı dene.',
        AuthFailureCode.emailNotConfirmed =>
          'E-posta adresin henüz doğrulanmadı. Gelen kutundaki bağlantıya tıkla.',
        AuthFailureCode.weakPassword =>
          'Şifre çok zayıf. Daha uzun ve tahmin edilmesi zor bir şifre seç.',
        AuthFailureCode.samePassword =>
          'Yeni şifre eskisiyle aynı olamaz.',
        AuthFailureCode.invalidEmail => 'Geçerli bir e-posta adresi gir.',
        AuthFailureCode.rateLimited =>
          'Çok fazla deneme yapıldı. Birkaç dakika sonra tekrar dene.',
        AuthFailureCode.network =>
          'İnternet bağlantısı yok. Bağlanıp tekrar dene.',
        AuthFailureCode.unavailable =>
          'Hesap sistemi şu anda kullanılamıyor. Uygulamayı hesapsız kullanmaya devam edebilirsin.',
        AuthFailureCode.unknown =>
          'Bir şeyler ters gitti. Lütfen tekrar dene.',
      };

  @override
  String toString() => 'AuthFailure($code)';
}

/// Sign-up password rule (matches the hint under the field).
String? validatePassword(String v) {
  if (v.length < 8) return 'En az 8 karakter girin';
  if (!v.contains(RegExp(r'\d'))) return 'En az bir rakam içermeli';
  return null;
}

/// What [AppState] needs from an account provider.
abstract class AuthService {
  /// False when no provider is configured (local-only builds and tests).
  bool get isAvailable;

  AuthUser? get currentUser;

  Stream<AuthEvent> get events;

  /// Throws [AuthFailure].
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Throws [AuthFailure].
  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  /// E-mails a reset link that opens the app. Throws [AuthFailure].
  Future<void> sendPasswordReset(String email);

  /// Sets a new password for the current (recovery) session. Throws
  /// [AuthFailure].
  Future<void> updatePassword(String newPassword);
}

/// Used when Supabase isn't configured: the app works fully offline and the
/// account screens explain that accounts aren't available.
class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  static const _failure = AuthFailure(AuthFailureCode.unavailable);

  @override
  bool get isAvailable => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthEvent> get events => const Stream.empty();

  @override
  Future<SignUpResult> signUp(
          {required String email,
          required String password,
          required String name}) =>
      Future.error(_failure);

  @override
  Future<void> signIn({required String email, required String password}) =>
      Future.error(_failure);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) => Future.error(_failure);

  @override
  Future<void> updatePassword(String newPassword) => Future.error(_failure);
}

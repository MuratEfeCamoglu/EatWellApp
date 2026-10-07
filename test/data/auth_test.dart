import 'package:denge/data/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every failure has a Turkish, user-facing message', () {
    for (final code in AuthFailureCode.values) {
      expect(AuthFailure(code).message, isNotEmpty, reason: code.name);
    }
    expect(const AuthFailure(AuthFailureCode.invalidCredentials).message,
        'E-posta veya şifre hatalı.');
    expect(const AuthFailure(AuthFailureCode.emailTaken).message,
        'Bu e-posta ile zaten bir hesap var. Giriş yapmayı dene.');
    expect(const AuthFailure(AuthFailureCode.network).message,
        'İnternet bağlantısı yok. Bağlanıp tekrar dene.');
  });

  test('validatePassword: at least 8 characters and a digit', () {
    expect(validatePassword(''), isNotNull);
    expect(validatePassword('abc1'), 'En az 8 karakter girin');
    expect(validatePassword('abcdefgh'), 'En az bir rakam içermeli');
    expect(validatePassword('abcdefg1'), isNull);
  });

  test('the unavailable service refuses everything politely', () async {
    const s = UnavailableAuthService();
    expect(s.isAvailable, isFalse);
    expect(s.currentUser, isNull);
    await expectLater(
      s.signIn(email: 'a@b.co', password: 'x'),
      throwsA(isA<AuthFailure>()
          .having((f) => f.code, 'code', AuthFailureCode.unavailable)),
    );
    await s.signOut(); // never throws
  });
}

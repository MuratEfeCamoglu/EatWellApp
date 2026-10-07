import 'dart:async';

import 'package:denge/data/auth.dart';

/// In-memory [AuthService] for tests: one registered account, optional
/// e-mail confirmation, and scripted failures.
class FakeAuthService implements AuthService {
  FakeAuthService({this.requireConfirmation = false});

  bool requireConfirmation;
  final _events = StreamController<AuthEvent>.broadcast();
  final Map<String, ({String password, String name, bool confirmed})> _users = {};
  AuthUser? _current;
  AuthFailure? nextFailure;
  final List<String> resetEmails = [];
  String? updatedPassword;

  void addUser(String email, String password,
          {String name = '', bool confirmed = true}) =>
      _users[email] = (password: password, name: name, confirmed: confirmed);

  /// Simulates the user tapping the reset link in their e-mail.
  void emitPasswordRecovery() => _events.add(AuthEvent.passwordRecovery);

  AuthFailure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  bool get isAvailable => true;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthEvent> get events => _events.stream;

  @override
  Future<SignUpResult> signUp(
      {required String email,
      required String password,
      required String name}) async {
    final f = _takeFailure();
    if (f != null) throw f;
    if (_users.containsKey(email)) {
      throw const AuthFailure(AuthFailureCode.emailTaken);
    }
    _users[email] =
        (password: password, name: name, confirmed: !requireConfirmation);
    if (requireConfirmation) return SignUpResult.needsEmailConfirmation;
    _current = AuthUser(id: 'u-$email', email: email, name: name);
    _events.add(AuthEvent.signedIn);
    return SignUpResult.signedIn;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final f = _takeFailure();
    if (f != null) throw f;
    final u = _users[email];
    if (u == null || u.password != password) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    if (!u.confirmed) throw const AuthFailure(AuthFailureCode.emailNotConfirmed);
    _current = AuthUser(id: 'u-$email', email: email, name: u.name);
    _events.add(AuthEvent.signedIn);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _events.add(AuthEvent.signedOut);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final f = _takeFailure();
    if (f != null) throw f;
    resetEmails.add(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final f = _takeFailure();
    if (f != null) throw f;
    updatedPassword = newPassword;
  }
}

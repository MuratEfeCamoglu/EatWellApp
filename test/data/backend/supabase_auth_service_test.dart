import 'package:denge/data/auth.dart';
import 'package:denge/data/backend/supabase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

void main() {
  AuthFailureCode map(Object e) => mapAuthError(e).code;

  test('Supabase error codes map to friendly failures', () {
    expect(map(const sb.AuthApiException('x', code: 'invalid_credentials')),
        AuthFailureCode.invalidCredentials);
    expect(map(const sb.AuthApiException('x', code: 'user_already_exists')),
        AuthFailureCode.emailTaken);
    expect(map(const sb.AuthApiException('x', code: 'email_exists')),
        AuthFailureCode.emailTaken);
    expect(map(const sb.AuthApiException('x', code: 'email_not_confirmed')),
        AuthFailureCode.emailNotConfirmed);
    expect(map(const sb.AuthApiException('x', code: 'over_email_send_rate_limit')),
        AuthFailureCode.rateLimited);
    expect(map(const sb.AuthApiException('x', code: 'over_request_rate_limit')),
        AuthFailureCode.rateLimited);
    expect(map(const sb.AuthApiException('x', code: 'same_password')),
        AuthFailureCode.samePassword);
    expect(map(const sb.AuthApiException('x', code: 'validation_failed')),
        AuthFailureCode.invalidEmail);
    expect(map(sb.AuthWeakPasswordException(
            message: 'weak', statusCode: '422', reasons: const [])),
        AuthFailureCode.weakPassword);
  });

  test('network problems are reported as such', () {
    expect(map(sb.AuthRetryableFetchException()), AuthFailureCode.network);
  });

  test('anything else is unknown, but still an AuthFailure', () {
    expect(map(const sb.AuthApiException('x', code: 'something_new')),
        AuthFailureCode.unknown);
    expect(map(StateError('boom')), AuthFailureCode.unknown);
  });

  test('deep link used for e-mail confirmation and password reset', () {
    expect(authRedirectUrl, 'com.denge.denge://login-callback');
  });
}

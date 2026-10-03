import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  AuthService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static String? get currentEmail => _client.auth.currentUser?.email;

  /// true return korle bujhbe email confirmation off, user already logged in.
  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);

    // Email age theke registered thakle Supabase error dey na,
    // kintu identities khali ashe. Sheta ekhane dhore feli.
    final identities = res.user?.identities;
    if (identities != null && identities.isEmpty) {
      throw const AuthException('User already registered');
    }
    return res.session != null;
  }

  static Future<void> verifySignupCode({
    required String email,
    required String code,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: code,
    );
    if (res.session == null) {
      throw const AuthException('Invalid or expired code');
    }
  }

  static Future<void> resendSignupCode(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> sendResetCode(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: code,
    );
    if (res.session == null) {
      throw const AuthException('Invalid or expired code');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Supabase er error ke user-friendly message e convert kore.
  static String friendlyError(Object e) {
    final raw = e is AuthException ? e.message : e.toString();
    final msg = raw.toLowerCase();

    if (msg.contains('invalid api key')) {
      return 'App setup problem: Invalid Supabase API key.';
    }
    if (msg.contains('invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email first.';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered')) {
      return 'This email is already registered. Please log in.';
    }
    if (msg.contains('rate limit') ||
        msg.contains('too many') ||
        msg.contains('security purposes')) {
      return 'Too many requests. Please wait a minute and try again.';
    }
    if (msg.contains('password should be')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    if (msg.contains('different from the old') ||
        msg.contains('same as the old')) {
      return 'New password must be different from the old one.';
    }
    if (msg.contains('session missing')) {
      return 'Session expired. Please request a new code.';
    }
    if (msg.contains('expired') ||
        msg.contains('otp') ||
        msg.contains('token')) {
      return 'Code is wrong or expired. Please try again.';
    }
    if (msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('clientexception') ||
        msg.contains('network')) {
      return 'No internet connection. Please check and try again.';
    }
    if (e is AuthException) return e.message;
    return 'Something went wrong. Please try again.';
  }
}
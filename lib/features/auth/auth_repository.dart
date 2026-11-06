import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

/// Thrown for user-facing sign-in failures (cancelled, no token, ...).
class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Wraps Google Sign-In + Supabase Auth. Google is the only login method.
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  static bool _googleInitialised = false;

  /// Must be called once at startup (after Supabase.initialize).
  static Future<void> initGoogle() async {
    if (_googleInitialised) return;
    await GoogleSignIn.instance.initialize(
      // Web client ID: required so the ID token's audience is accepted by Supabase.
      serverClientId: Env.googleWebClientId.isEmpty ? null : Env.googleWebClientId,
    );
    _googleInitialised = true;
  }

  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthFailure('Google did not return an ID token. Check GOOGLE_WEB_CLIENT_ID.');
      }
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      await ensureProfile();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthFailure('Sign-in cancelled.');
      }
      throw AuthFailure('Google sign-in failed (${e.code.name}).');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  /// The DB trigger normally creates the profile on signup. This is a
  /// safety net (e.g. accounts created before the migration ran).
  Future<void> ensureProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final existing =
        await _client.from('profiles').select('id').eq('id', user.id).maybeSingle();
    if (existing != null) return;
    final meta = user.userMetadata ?? const {};
    await _client.from('profiles').insert({
      'id': user.id,
      'email': user.email,
      'full_name': meta['full_name'] ?? meta['name'],
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google session may already be gone; Supabase sign-out is what matters.
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(supabase));

/// Emits on every auth change; screens/router react to it.
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).authChanges,
);

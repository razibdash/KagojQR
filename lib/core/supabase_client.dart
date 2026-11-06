import 'package:supabase_flutter/supabase_flutter.dart';

/// Build-time config, injected with `--dart-define-from-file=.env`.
/// Only the public anon key is ever shipped in the app.
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const viewerBaseUrl =
      String.fromEnvironment('VIEWER_BASE_URL', defaultValue: 'https://kagojqr.app/v');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

Future<void> initSupabase() async {
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
}

SupabaseClient get supabase => Supabase.instance.client;

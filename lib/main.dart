import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/supabase_client.dart';
import 'features/auth/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    // Fail loudly and helpfully instead of crashing inside Supabase.
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing config.\nRun with: flutter run --dart-define-from-file=.env\n'
              '(copy .env.example to .env first)',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }

  await initSupabase();
  await AuthRepository.initGoogle();
  runApp(const ProviderScope(child: KagojQrApp()));
}

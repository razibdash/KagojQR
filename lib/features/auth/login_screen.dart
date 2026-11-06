import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Router redirect moves us to Home once the session exists.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/logo/logo.png', width: 112, height: 112),
              const SizedBox(height: Gap.m),
              Text('KagojQR',
                  style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: Gap.s),
              Text('গাড়ির কাগজ, QR-এ।\nGari-r kagoj, QR-e.',
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: AppColors.textSecondary)),
              const Spacer(flex: 3),
              if (_error != null) ...[
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: AppColors.danger)),
                const SizedBox(height: Gap.m),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _signIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: Color(0xFFDDE3E0)),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login_rounded),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: Gap.m),
            ],
          ),
        ),
      ),
    );
  }
}

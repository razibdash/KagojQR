import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../auth/auth_repository.dart';

/// Phase 2 placeholder: shows the signed-in profile. Document list arrives in Phase 3.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('KagojQR'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Gap.m),
        child: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load your profile.'),
                const SizedBox(height: Gap.s),
                OutlinedButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (p) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              title: Text(p['full_name'] as String? ?? 'Unnamed'),
              subtitle: Text(p['email'] as String? ?? ''),
            ),
          ),
        ),
      ),
    );
  }
}

/// The signed-in user's profile row (RLS limits this to their own row).
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(authStateProvider); // refetch when the user changes
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) throw StateError('Not signed in');
  await ref.read(authRepositoryProvider).ensureProfile();
  return await supabase.from('profiles').select().eq('id', uid).single();
});

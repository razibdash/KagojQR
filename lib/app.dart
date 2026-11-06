import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';

class KagojQrApp extends ConsumerWidget {
  const KagojQrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'KagojQR',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

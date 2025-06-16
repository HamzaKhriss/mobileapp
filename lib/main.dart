import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'state/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: CasaWondersApp()));
}

class CasaWondersApp extends ConsumerWidget {
  const CasaWondersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Casa Wonders',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

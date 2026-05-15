import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init(); // Inicializa Dio + interceptors
  runApp(
    const ProviderScope(
      child: HealUpApp(),
    ),
  );
}

class HealUpApp extends StatelessWidget {
  const HealUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HealUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

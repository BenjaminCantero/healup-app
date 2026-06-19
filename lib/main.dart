import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/api_client.dart';
import 'presentation/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a container so we can pass a force-logout callback into
  // the Dio interceptor. This fixes the zombie-session bug: when a
  // token refresh fails, the interceptor now reactively clears the
  // Riverpod auth state so the UI immediately redirects to login.
  final container = ProviderContainer();

  ApiClient.instance.init(
    onForceLogout: () async {
      await container.read(authProvider.notifier).logout();
    },
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HealUpApp(),
    ),
  );
}

class HealUpApp extends ConsumerWidget {
  const HealUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'HealUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

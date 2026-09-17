import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/updates/app_update_service.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/portal_auth/presentation/controllers/portal_auth_controllers.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

const _loadingHome = Scaffold(body: Center(child: CircularProgressIndicator()));

class MisApp extends ConsumerStatefulWidget {
  const MisApp({super.key});

  @override
  ConsumerState<MisApp> createState() => _MisAppState();
}

class _MisAppState extends ConsumerState<MisApp> {
  bool _updateCheckStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_updateCheckStarted) {
      _updateCheckStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final update = await AppUpdateService().check();
      if (update == null) return;
      final navContext = appNavigatorKey.currentContext;
      if (navContext == null) return;

      final install = await showDialog<bool>(
        context: navContext,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Update available'),
          content: Text(
            'ARMSS Gateway ${update.version} is available. Update now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Update'),
            ),
          ],
        ),
      );
      if (install != true) return;
      await AppUpdateService().install(update);
    } catch (e) {
      debugPrint('[APP_UPDATE_ERROR] Failed to check or show update dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final portalSessionAsync = ref.watch(portalSessionControllerProvider);
    final Widget home = portalSessionAsync.when(
      loading: () => _loadingHome,
      error: (_, _) => const LoginScreen(),
      data: (session) =>
          session == null ? const LoginScreen() : const AppShell(),
    );

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'ARMSS Gateway',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}

import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/health/health_screen.dart';
import 'features/home/home_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/watch_faces/watch_faces_screen.dart';
import 'state/lynio_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LynioApp());
}

class LynioApp extends StatefulWidget {
  const LynioApp({super.key, this.controller});

  final LynioController? controller;

  @override
  State<LynioApp> createState() => _LynioAppState();
}

class _LynioAppState extends State<LynioApp> {
  late final LynioController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? LynioController();
    if (!_controller.isInitialized) {
      _controller.initialize();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'iHealthFit',
          debugShowCheckedModeBanner: false,
          theme: LynioTheme.light(),
          darkTheme: LynioTheme.dark(),
          themeMode: _controller.themeMode,
          home: !_controller.isInitialized
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : !_controller.onboardingCompleted
                  ? OnboardingScreen(controller: _controller)
                  : _LynioMainShell(controller: _controller),
        );
      },
    );
  }
}

class _LynioMainShell extends StatefulWidget {
  const _LynioMainShell({required this.controller});

  final LynioController controller;

  @override
  State<_LynioMainShell> createState() => _LynioMainShellState();
}

class _LynioMainShellState extends State<_LynioMainShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        controller: widget.controller,
        onNavigateTab: (index) => setState(() => _tabIndex = index),
      ),
      WatchFacesScreen(controller: widget.controller),
      NotificationsScreen(controller: widget.controller),
      HealthScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette_rounded),
            label: 'Faces',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

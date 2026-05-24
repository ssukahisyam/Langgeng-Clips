import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    this.currentIndex = 0,
    this.actions,
    super.key,
  });

  final String title;
  final Widget child;
  final int currentIndex;
  final List<Widget>? actions;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  DateTime? _lastHomeBackPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        if (widget.currentIndex != 0) {
          context.go('/home');
          return;
        }

        final now = DateTime.now();
        final shouldExit =
            _lastHomeBackPressedAt != null &&
            now.difference(_lastHomeBackPressedAt!) <
                const Duration(seconds: 2);
        if (shouldExit) {
          SystemNavigator.pop();
          return;
        }

        _lastHomeBackPressedAt = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tekan sekali lagi untuk keluar')),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: widget.actions),
        body: SafeArea(child: widget.child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/home');
              case 1:
                context.go('/library');
              case 2:
                context.go('/settings');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_library_outlined),
              selectedIcon: Icon(Icons.video_library),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

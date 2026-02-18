import 'package:flutter/material.dart';
import 'package:hymnal_app/layers/screens/home/home_screen.dart';
import 'package:hymnal_app/layers/screens/lists/lists_screen.dart';
import 'package:hymnal_app/layers/screens/favorites/favorites_screen.dart';
import 'package:hymnal_app/layers/screens/settings/settings_screen.dart';
import 'package:hymnal_app/widgets/app_scaffold.dart';
import 'package:hymnal_app/l10n/generated/app_localizations.dart';

part 'main_tabs_controller.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends _MainTabsController {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.lists,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
      playerBottomOffset: 56.0, // Standard BottomNavigationBar height
    );
  }
}

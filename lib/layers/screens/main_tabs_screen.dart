import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/home/home_screen.dart';
import 'package:hymnal_app/layers/screens/lists/lists_screen.dart';
import 'package:hymnal_app/layers/screens/favorites/favorites_screen.dart';
import 'package:hymnal_app/layers/screens/settings/settings_screen.dart';
import 'package:hymnal_app/layers/screens/player/player_bar.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ListsScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsService,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            if (_settingsService.showBackgroundImage)
              Positioned.fill(
                child: Image.asset(
                  'assets/background_image.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.15),
                ),
              ),
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  Expanded(
                    child: _screens[_currentIndex],
                  ),
                  const PlayerBar(),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Lists',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

part of 'main_tabs_screen.dart';

abstract class _MainTabsController extends State<MainTabsScreen> {
  int _currentIndex = 0;
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ListsScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

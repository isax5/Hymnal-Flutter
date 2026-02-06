import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();

  @override
  void initState() {
    super.initState();
    _favoritesService.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_settingsService, _favoritesService]),
      builder: (context, child) {
        final favorites = _favoritesService.favorites;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
          ),
          body: favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add hymns to your favorites from the hymn page',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: favorites.length,
                  onReorder: _favoritesService.reorderFavorites,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return ListTile(
                      key: ValueKey(favorite),
                      leading: CircleAvatar(
                        child: Text('${favorite.hymnNumber}'),
                      ),
                      title: Text(favorite.title),
                      subtitle: Text(_getHymnalName(favorite.hymnalId)),
                      trailing: const Icon(Icons.drag_handle),
                      onTap: () async {
                        await _historyService.addToHistory(
                          favorite.hymnalId,
                          favorite.hymnNumber,
                          favorite.title,
                        );
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HymnScreen(
                                hymnalId: favorite.hymnalId,
                                hymnNumber: favorite.hymnNumber,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  String _getHymnalName(String hymnalId) {
    final hymnal = _settingsService.hymnals.firstWhere(
      (h) => h.id == hymnalId,
      orElse: () => _settingsService.hymnals.first,
    );
    return hymnal.name;
  }
}

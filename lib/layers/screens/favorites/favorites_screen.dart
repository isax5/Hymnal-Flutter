import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/domain/model/favorite_hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

part 'favorites_controller.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends _FavoritesController {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_settingsService, _favoritesService]),
      builder: (context, child) {
        final favorites = _favoritesService.favorites;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).orientation == Orientation.landscape ? 40 : null,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
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
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: favorites.length,
                  onReorder: _favoritesService.reorderFavorites,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return Dismissible(
                      key: ValueKey(favorite),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) => _confirmDismiss(favorite),
                      onDismissed: (_) => _onDismissed(favorite),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                          child: Text(
                            '${favorite.hymnNumber}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(favorite.title),
                        subtitle: Text(_getHymnalName(favorite.hymnalId)),
                        trailing: const Icon(Icons.drag_handle),
                        onTap: () => _onFavoriteTapped(favorite),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

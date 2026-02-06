import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymnal_app/layers/domain/model/favorite_hymn.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteHymn>> getFavorites();
  Future<void> addFavorite(FavoriteHymn favorite);
  Future<void> removeFavorite(String hymnalId, int hymnNumber);
  Future<bool> isFavorite(String hymnalId, int hymnNumber);
  Future<void> reorderFavorites(List<FavoriteHymn> favorites);
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  static const String _favoritesKey = 'favorites';

  @override
  Future<List<FavoriteHymn>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final favorites = jsonList.map((e) => FavoriteHymn.fromJson(e)).toList();

    favorites.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

    return favorites;
  }

  @override
  Future<void> addFavorite(FavoriteHymn favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (!await isFavorite(favorite.hymnalId, favorite.hymnNumber)) {
      favorites.add(favorite);
      await _saveFavorites(favorites);
    }
  }

  @override
  Future<void> removeFavorite(String hymnalId, int hymnNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere(
      (f) => f.hymnalId == hymnalId && f.hymnNumber == hymnNumber,
    );

    await _saveFavorites(favorites);
  }

  @override
  Future<bool> isFavorite(String hymnalId, int hymnNumber) async {
    final favorites = await getFavorites();
    return favorites.any(
      (f) => f.hymnalId == hymnalId && f.hymnNumber == hymnNumber,
    );
  }

  @override
  Future<void> reorderFavorites(List<FavoriteHymn> favorites) async {
    await _saveFavorites(favorites);
  }

  Future<void> _saveFavorites(List<FavoriteHymn> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((e) => e.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonList));
  }
}

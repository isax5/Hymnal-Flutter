part of 'favorites_screen.dart';

abstract class _FavoritesController extends State<FavoritesScreen> {
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();

  @override
  void initState() {
    super.initState();
    _favoritesService.loadFavorites();
  }

  String _getHymnalName(String hymnalId) {
    final hymnal = _settingsService.hymnals.firstWhere(
      (h) => h.id == hymnalId,
      orElse: () => _settingsService.hymnals.first,
    );
    return hymnal.name;
  }

  Future<void> _onFavoriteTapped(FavoriteHymn favorite) async {
    await _historyService.addToHistory(
      favorite.hymnalId,
      favorite.hymnNumber,
      favorite.title,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/hymn'),
          builder: (_) => HymnScreen(
            hymnalId: favorite.hymnalId,
            hymnNumber: favorite.hymnNumber,
          ),
        ),
      );
    }
  }

  Future<bool?> _confirmDismiss(FavoriteHymn favorite) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Remove "${favorite.title}" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _onDismissed(FavoriteHymn favorite) {
    _favoritesService.removeFavorite(
      favorite.hymnalId,
      favorite.hymnNumber,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${favorite.title} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _favoritesService.addFavorite(
              favorite.hymnalId,
              favorite.hymnNumber,
              favorite.title,
            );
          },
        ),
      ),
    );
  }
}

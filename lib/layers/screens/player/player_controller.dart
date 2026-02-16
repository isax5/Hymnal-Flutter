part of 'player_screen.dart';

abstract class _PlayerController extends State<PlayerScreen> {
  final AudioService _audioService = GetIt.I<AudioService>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _audioService.addListener(_checkFavorite);
  }

  @override
  void dispose() {
    _audioService.removeListener(_checkFavorite);
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final hymn = _audioService.currentHymn;
    final hymnal = _audioService.currentHymnal;

    if (hymn != null && hymnal != null) {
      final isFav = await _favoritesService.isFavorite(hymnal.id, hymn.number);
      if (mounted && isFav != _isFavorite) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final hymn = _audioService.currentHymn;
    final hymnal = _audioService.currentHymnal;

    if (hymn != null && hymnal != null) {
      await _favoritesService.toggleFavorite(hymnal.id, hymn.number, hymn.title);
      await _checkFavorite();
    }
  }

  void _shareHymn() {
    final hymn = _audioService.currentHymn;
    if (hymn != null) {
      Share.share(
        '${hymn.title}\n\nShared from Hymnal App',
        subject: hymn.title,
      );
    }
  }

  void _openHymnPage(BuildContext context, String hymnalId, int hymnNumber) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/hymn'),
        builder: (_) => HymnScreen(
          hymnalId: hymnalId,
          hymnNumber: hymnNumber,
          skipHistory: true,
        ),
      ),
      (route) {
        return route.settings.name != '/hymn' && route.settings.name != '/player';
      },
    );
  }
}

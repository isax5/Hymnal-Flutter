part of 'player_screen.dart';

abstract class _PlayerController extends State<PlayerScreen> {
  final AudioService _audioService = GetIt.I<AudioService>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _audioService.addListener(_checkFavorite);
    _favoritesService.addListener(_checkFavorite);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavorite();
    });
  }

  @override
  void dispose() {
    _audioService.removeListener(_checkFavorite);
    _favoritesService.removeListener(_checkFavorite);
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
    final l10n = AppLocalizations.of(context)!;
    final hymn = _audioService.currentHymn;
    final hymnal = _audioService.currentHymnal;

    if (hymn != null) {
      final text = '''${hymn.title}

${hymn.content}''';

      final message = AppLinks.getShareMessage(
        text,
        l10n.sharedFromApp(AppLinks.appStoreUrl, AppLinks.playStoreUrl),
        hymnNumber: hymn.number.toString(),
        hymnTitle: hymnal!.name,
      );
      SharePlus.instance.share(ShareParams(text: message));
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

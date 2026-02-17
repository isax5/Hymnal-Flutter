part of 'hymn_screen.dart';

abstract class _HymnController extends State<HymnScreen> {
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final AudioService _audioService = GetIt.I<AudioService>();

  Hymnal? _hymnal;
  Hymn? _hymn;
  MusicSettings? _musicSettings;
  PageController? _pageController;
  List<Hymn>? _allHymns;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
    _loadData();
  }

  void _onFavoritesChanged() {
    if (_hymn != null && mounted) {
      _favoritesService
          .isFavorite(widget.hymnalId, _hymn!.number)
          .then((isFav) {
        if (mounted && isFav != _isFavorite) {
          setState(() {
            _isFavorite = isFav;
          });
        }
      });
    }
  }

  Future<void> _loadData() async {
    final hymnals = await _repository.getHymnals();
    _hymnal = hymnals.firstWhere((h) => h.id == widget.hymnalId);

    _allHymns = await _repository.getHymns(widget.hymnalId);
    _hymn = _allHymns!.firstWhere((h) => h.number == widget.hymnNumber);

    _musicSettings = await _repository.getMusicSettings(widget.hymnalId);

    _isFavorite = await _favoritesService.isFavorite(
      widget.hymnalId,
      widget.hymnNumber,
    );

    final initialPage =
        _allHymns!.indexWhere((h) => h.number == widget.hymnNumber);
    _pageController = PageController(initialPage: initialPage);

    // Only add to history if not skipped
    if (!widget.skipHistory) {
      await _historyService.addToHistory(
        widget.hymnalId,
        _hymn!.number,
        _hymn!.title,
      );
    }

    if (_settingsService.keepScreenOn) {
      try {
        await WakelockPlus.enable();
      } catch (e) {
        debugPrint('Warning: Failed to enable wakelock: $e');
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _onPageChanged(int index) async {
    final hymn = _allHymns![index];
    setState(() {
      _hymn = hymn;
    });

    // Only add to history if not skipped
    if (!widget.skipHistory) {
      await _historyService.addToHistory(
        widget.hymnalId,
        hymn.number,
        hymn.title,
      );
    }

    _isFavorite = await _favoritesService.isFavorite(
      widget.hymnalId,
      hymn.number,
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(
      widget.hymnalId,
      _hymn!.number,
      _hymn!.title,
    );

    _isFavorite = await _favoritesService.isFavorite(
      widget.hymnalId,
      _hymn!.number,
    );

    if (mounted) setState(() {});
  }

  Future<void> _shareHymn() async {
    final l10n = AppLocalizations.of(context)!;
    final text = '''${_hymn!.title}

${_hymn!.content}

${l10n.sharedFromApp}''';

    await Share.share(text);
  }

  void _openSheets() {
    if (_hymnal?.hymnsSheetsFileName == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SheetsScreen(
          hymnal: _hymnal!,
          hymnNumber: _hymn!.number,
        ),
      ),
    );
  }

  Future<void> _playAudio({bool instrumental = true}) async {
    final url = instrumental
        ? _musicSettings?.getInstrumentalUrl(_hymn!.number)
        : _musicSettings?.getSungUrl(_hymn!.number);

    if (url != null) {
      try {
        await _audioService.playHymn(_hymnal!, _hymn!, url,
            instrumental: instrumental);
      } catch (e) {
        debugPrint('Failed to play audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    try {
      WakelockPlus.disable();
    } catch (e) {
      debugPrint('Warning: Failed to disable wakelock: $e');
    }
    _pageController?.dispose();
    super.dispose();
  }
}

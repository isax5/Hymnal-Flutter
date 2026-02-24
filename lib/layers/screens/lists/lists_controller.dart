part of 'lists_screen.dart';

abstract class _ListsController extends State<ListsScreen> {
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();

  List<Hymn>? _hymns;
  List<ThematicCategory>? _thematicList;
  List<Hymn>? _sortedHymns;
  List<String>? _indexBarData;
  String? _lastHymnalId;

  @override
  void initState() {
    super.initState();

    _settingsService.addListener(_onSettingsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (_lastHymnalId != _settingsService.selectedHymnal?.id) {
      setState(() {
        _hymns = null;
        _thematicList = null;
        _sortedHymns = null;
        _indexBarData = null;
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) return;

    _lastHymnalId = hymnal.id;

    final hymns = await _repository.getHymns(hymnal.id);
    final thematic = await _repository.getThematicList(hymnal.id);

    // Pre-calculate sorted list and index bar data for Alphabetic tab
    final sortedHymns = List<Hymn>.from(hymns)
      ..sort((a, b) {
        final tagA = _getFirstLetter(a.title);
        final tagB = _getFirstLetter(b.title);
        final comparison = tagA.compareTo(tagB);
        if (comparison != 0) return comparison;

        String normalizeTitle(String s) {
          var t = s.trim();
          t = t.replaceFirst(RegExp(r'^[^A-Za-z0-9]+'), '');
          return t.toLowerCase();
        }

        return normalizeTitle(a.title).compareTo(normalizeTitle(b.title));
      });

    SuspensionUtil.setShowSuspensionStatus(sortedHymns);

    final presentTags = <String>{};
    for (final hymn in sortedHymns) {
      presentTags.add(hymn.getSuspensionTag());
    }
    final List<String> indexBarData = presentTags.where((t) => t != '#').toList()
      ..sort((a, b) {
        final na = StringUtils.normalize(a);
        final nb = StringUtils.normalize(b);
        return na.compareTo(nb);
      });
    if (presentTags.contains('#')) indexBarData.add('#');

    if (mounted) {
      setState(() {
        _hymns = hymns;
        _thematicList = thematic;
        _sortedHymns = sortedHymns;
        _indexBarData = indexBarData;
      });
    }
  }

  String _getFirstLetter(String title) {
    final norm = StringUtils.normalize(title);
    if (norm.isEmpty) return '#';
    for (int i = 0; i < norm.length; i++) {
      final char = norm[i].toUpperCase();
      if (RegExp(r'\p{L}', unicode: true).hasMatch(char)) {
        return char;
      }
    }
    return '#';
  }

  Future<void> _openHymn(Hymn hymn) async {
    final hymnal = _settingsService.selectedHymnal!;
    await _historyService.addToHistory(hymnal.id, hymn.number, hymn.title);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/hymn'),
          builder: (_) => HymnScreen(
            hymnalId: hymnal.id,
            hymnNumber: hymn.number,
          ),
        ),
      );
    }
  }
}

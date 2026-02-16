part of 'lists_screen.dart';

abstract class _ListsController extends State<ListsScreen> {
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();

  List<Hymn>? _hymns;
  List<ThematicCategory>? _thematicList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) return;

    final hymns = await _repository.getHymns(hymnal.id);
    final thematic = await _repository.getThematicList(hymnal.id);

    setState(() {
      _hymns = hymns;
      _thematicList = thematic;
    });
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

part of 'search_screen.dart';

abstract class _SearchController extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  List<Hymn> _results = [];
  List<Hymn> _allHymns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final hymnalId = _settingsService.selectedHymnal?.id;
      if (hymnalId == null) return;

      final hymns = await _repository.getHymns(hymnalId);
      if (mounted) {
        setState(() {
          _allHymns = hymns;
          if (_searchController.text.isEmpty) {
            _results = hymns;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _results = _allHymns;
          _isLoading = false;
        });
      }
      return;
    }
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final hymnalId = _settingsService.selectedHymnal?.id;
      if (hymnalId == null) return;

      final results = await _repository.searchHymns(hymnalId, query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openHymn(Hymn hymn) {
    if (_settingsService.selectedHymnal == null) return;

    // Unfocus keyboard before navigating
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/hymn'),
        builder: (_) => HymnScreen(
          hymnalId: _settingsService.selectedHymnal!.id,
          hymnNumber: hymn.number,
        ),
      ),
    );
  }
}

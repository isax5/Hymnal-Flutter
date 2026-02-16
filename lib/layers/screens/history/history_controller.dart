part of 'history_screen.dart';

abstract class _HistoryController extends State<HistoryScreen> {
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  @override
  void initState() {
    super.initState();
    _historyService.loadHistory();
  }

  Future<void> _openHymn(String hymnalId, int hymnNumber, String title) async {
    // Don't add to history when opening from history
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/hymn'),
          builder: (_) => HymnScreen(
            hymnalId: hymnalId,
            hymnNumber: hymnNumber,
            skipHistory: true,
          ),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
    }
  }

  String _getHymnalName(String hymnalId) {
    final hymnal = _settingsService.hymnals.firstWhere(
      (h) => h.id == hymnalId,
      orElse: () => _settingsService.hymnals.first,
    );
    return hymnal.name;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

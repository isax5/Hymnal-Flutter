part of 'home_screen.dart';

abstract class _HomeController extends State<HomeScreen> {
  // Imports are handled by the part file
  final TextEditingController _numberController = TextEditingController();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _openHymn() async {
    final numberText = _numberController.text.trim();
    if (numberText.isEmpty) {
      _showError('Please enter a hymn number');
      return;
    }

    final number = int.tryParse(numberText);
    if (number == null || number <= 0) {
      _showError('Please enter a valid number');
      return;
    }

    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) {
      _showError('No hymnal selected');
      return;
    }

    final hymn =
        await GetIt.I<HymnalRepository>().getHymnByNumber(hymnal.id, number);
    if (hymn == null) {
      _showError('Hymn not found');
      return;
    }

    await _historyService.addToHistory(hymnal.id, hymn.number, hymn.title);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HymnScreen(
            hymnalId: hymnal.id,
            hymnNumber: hymn.number,
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

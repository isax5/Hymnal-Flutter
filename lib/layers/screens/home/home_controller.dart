part of 'home_screen.dart';

abstract class _HomeController extends State<HomeScreen> {
  // Imports are handled by the part file
  final TextEditingController _numberController = TextEditingController();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final FocusNode _numberFocusNode = FocusNode();

  // @override
  // void initState() {
  //   super.initState();
  //   // Auto-focus the input field when screen opens
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Future.delayed(const Duration(milliseconds: 300), () {
  //       if (mounted) {
  //         _numberFocusNode.requestFocus();
  //       }
  //     });
  //   });
  // }

  @override
  void dispose() {
    _numberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  void _unfocusKeyboard() {
    _numberFocusNode.unfocus();
  }

  Future<void> _openHymn() async {
    final numberText = _numberController.text.trim();
    if (numberText.isEmpty) {
      _numberFocusNode.requestFocus();
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
          settings: const RouteSettings(name: '/hymn'),
          builder: (_) => HymnScreen(
            hymnalId: hymnal.id,
            hymnNumber: hymn.number,
          ),
        ),
      );
    }
  }

  Future<void> _showHymnalSelector() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Hymnal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._settingsService.hymnals.map((hymnal) {
              final isSelected =
                  hymnal.id == _settingsService.selectedHymnal?.id;
              return ListTile(
                leading: Text(
                  hymnal.twoLetterIsoLanguageName.toUpperCase(),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                title: Text(hymnal.name),
                subtitle: Text('${hymnal.year} • ${hymnal.detail}'),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  _settingsService.selectHymnal(hymnal.id);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
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

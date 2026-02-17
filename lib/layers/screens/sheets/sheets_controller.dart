part of 'sheets_screen.dart';

abstract class _SheetsController extends State<SheetsScreen> {
  List<String> _sheetUrls = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAppBarVisible = true;

  void _toggleAppBar() {
    if (mounted) {
      setState(() {
        _isAppBarVisible = !_isAppBarVisible;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSheets();
    });
  }

  Future<void> _loadSheets() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.hymnal.hymnsSheetsFileName == null) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.noSheetMusicAvailable;
          _isLoading = false;
        });
      }
      return;
    }

    final baseName = widget.hymnal.hymnsSheetsFileName!.replaceAll(
      '###',
      widget.hymnNumber.toString().padLeft(3, '0'),
    );

    final urls = <String>[];

    // Check for base sheet
    final baseUrl = 'assets/musicSheets/$baseName';
    if (await _assetExists(baseUrl)) {
      urls.add(baseUrl);
    }

    // Check for additional pages
    for (int i = 1; i <= 6; i++) {
      final extraName = baseName.replaceAll('.png', '_$i.png');
      final extraUrl = 'assets/musicSheets/$extraName';
      if (await _assetExists(extraUrl)) {
        urls.add(extraUrl);
      }
    }

    if (mounted) {
      setState(() {
        _sheetUrls = urls;
        _isLoading = false;
        if (urls.isEmpty) {
          _errorMessage = l10n.noSheetMusicFound(widget.hymnNumber);
        }
      });
    }
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}

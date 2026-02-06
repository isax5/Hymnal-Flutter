import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:hymnal_app/layers/domain/model/music_settings.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/layers/screens/sheets/sheets_screen.dart';

class HymnScreen extends StatefulWidget {
  final String hymnalId;
  final int hymnNumber;

  const HymnScreen({
    super.key,
    required this.hymnalId,
    required this.hymnNumber,
  });

  @override
  State<HymnScreen> createState() => _HymnScreenState();
}

class _HymnScreenState extends State<HymnScreen> {
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
    _loadData();
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

    await _historyService.addToHistory(
      widget.hymnalId,
      _hymn!.number,
      _hymn!.title,
    );

    if (_settingsService.keepScreenOn) {
      WakelockPlus.enable();
    }

    setState(() {});
  }

  Future<void> _onPageChanged(int index) async {
    final hymn = _allHymns![index];
    setState(() {
      _hymn = hymn;
    });

    await _historyService.addToHistory(
      widget.hymnalId,
      hymn.number,
      hymn.title,
    );

    _isFavorite = await _favoritesService.isFavorite(
      widget.hymnalId,
      hymn.number,
    );
    setState(() {});
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

    setState(() {});
  }

  Future<void> _shareHymn() async {
    final text = '''${_hymn!.title}

${_hymn!.content}

Shared from Hymnal App''';

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
      await _audioService.playHymn(_hymn!, _hymnal!, url,
          instrumental: instrumental);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hymn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasSheets = _hymnal?.hymnsSheetsFileName != null;
    final hasInstrumental =
        _musicSettings?.getInstrumentalUrl(_hymn!.number) != null;
    final hasSung = _musicSettings?.getSungUrl(_hymn!.number) != null;
    final hasAudio = hasInstrumental || hasSung;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn ${_hymn!.number}'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareHymn,
          ),
          if (hasSheets)
            IconButton(
              icon: const Icon(Icons.music_note),
              onPressed: _openSheets,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _allHymns?.length ?? 0,
        itemBuilder: (context, index) {
          final hymn = _allHymns![index];
          return _buildHymnContent(hymn);
        },
      ),
      bottomNavigationBar: hasAudio
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasInstrumental)
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.piano),
                        title: const Text('Instrumental'),
                        onTap: () => _playAudio(instrumental: true),
                      ),
                    ),
                  if (hasSung)
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.mic),
                        title: const Text('Sung'),
                        onTap: () => _playAudio(instrumental: false),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildHymnContent(Hymn hymn) {
    return AnimatedBuilder(
      animation: _settingsService,
      builder: (context, child) {
        return Container(
          decoration: _settingsService.showBackgroundImage
              ? BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/background_image.png'),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                )
              : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hymn.title,
                  style: TextStyle(
                    fontSize: _settingsService.fontSize + 4,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_hymnal?.detail} • #${hymn.number}',
                  style: TextStyle(
                    fontSize: _settingsService.fontSize - 2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  hymn.content,
                  style: TextStyle(
                    fontSize: _settingsService.fontSize,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

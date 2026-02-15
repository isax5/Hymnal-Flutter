import 'package:flutter/material.dart';
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
import 'package:hymnal_app/layers/screens/player/player_bar.dart';

class HymnScreen extends StatefulWidget {
  final String hymnalId;
  final int hymnNumber;
  final bool skipHistory;

  const HymnScreen({
    super.key,
    required this.hymnalId,
    required this.hymnNumber,
    this.skipHistory = false,
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

    final initialPage = _allHymns!.indexWhere((h) => h.number == widget.hymnNumber);
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

    setState(() {});
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
      try {
        await _audioService.playHymn(_hymnal!, _hymn!, url, instrumental: instrumental);
      } catch (e) {
        debugPrint('Failed to play audio: $e');
      }
    }
  }

  Widget _buildAudioButtons(bool hasInstrumental, bool hasSung) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? 50 : 60,
      padding: const EdgeInsets.only(bottom: 0, top: 2),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasInstrumental)
                Expanded(
                  child: InkWell(
                    onTap: () => _playAudio(instrumental: true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 0 : 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.piano, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Instrumental',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (hasSung && hasInstrumental)
                VerticalDivider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1,
                ),
              if (hasSung)
                Expanded(
                  child: InkWell(
                    onTap: () => _playAudio(instrumental: false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 0 : 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.record_voice_over, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Sung',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      WakelockPlus.disable();
    } catch (e) {
      debugPrint('Warning: Failed to disable wakelock: $e');
    }
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
    final hasInstrumental = _musicSettings?.getInstrumentalUrl(_hymn!.number) != null;
    final hasSung = _musicSettings?.getSungUrl(_hymn!.number) != null;
    final hasAudio = hasInstrumental || hasSung;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        AnimatedBuilder(
          animation: _settingsService,
          builder: (context, child) {
            if (!_settingsService.showBackgroundImage) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: Image.asset(
                'assets/background_image.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.1),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            toolbarHeight: isLandscape ? 40 : null,
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
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _allHymns?.length ?? 0,
                  itemBuilder: (context, index) {
                    final hymn = _allHymns![index];
                    return _buildHymnContent(hymn);
                  },
                ),
              ),
              const PlayerBar(),
            ],
          ),
          bottomNavigationBar: hasAudio ? _buildAudioButtons(hasInstrumental, hasSung) : null,
        ),
      ],
    );
  }

  Widget _buildHymnContent(Hymn hymn) {
    return AnimatedBuilder(
      animation: _settingsService,
      builder: (context, child) {
        return Container(
          // Background is now handled in the parent Stack
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

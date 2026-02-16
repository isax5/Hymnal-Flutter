import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';

class SheetsScreen extends StatefulWidget {
  final Hymnal hymnal;
  final int hymnNumber;

  const SheetsScreen({
    super.key,
    required this.hymnal,
    required this.hymnNumber,
  });

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  List<String> _sheetUrls = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    if (widget.hymnal.hymnsSheetsFileName == null) {
      setState(() {
        _errorMessage = 'No sheet music available for this hymnal';
        _isLoading = false;
      });
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

    setState(() {
      _sheetUrls = urls;
      _isLoading = false;
      if (urls.isEmpty) {
        _errorMessage = 'No sheet music found for hymn ${widget.hymnNumber}';
      }
    });
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return AnimatedBuilder(
      animation: GetIt.I<SettingsService>(),
      builder: (context, child) {
        final settingsService = GetIt.I<SettingsService>();
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            if (settingsService.showBackgroundImage)
              Positioned.fill(
                child: Image.asset(
                  'assets/background_image.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.15),
                ),
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
                title: Text('Sheet Music - Hymn ${widget.hymnNumber}'),
                actions: [
                  if (_sheetUrls.length > 1)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${_currentIndex + 1}/${_sheetUrls.length}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : PhotoViewGallery.builder(
                          itemCount: _sheetUrls.length,
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: AssetImage(_sheetUrls[index]),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error, color: Colors.red),
                                      const SizedBox(height: 8),
                                      Text('Failed to load image: $error'),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          pageController: PageController(initialPage: 0),
                          scrollPhysics: const BouncingScrollPhysics(),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
            ),
            const DraggablePlayer(),
          ],
        );
      },
    );
  }
}

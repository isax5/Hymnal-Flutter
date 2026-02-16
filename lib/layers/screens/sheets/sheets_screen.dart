import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';

part 'sheets_controller.dart';

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

class _SheetsScreenState extends _SheetsController {
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
              body: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: _isLoading
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
                            onPageChanged: _onPageChanged,
                            pageController: PageController(initialPage: 0),
                            scrollPhysics: const BouncingScrollPhysics(),
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
              ),
            ),
            DraggablePlayer(
              includeSafeArea: false,
              bottomPadding: isLandscape ? 20 : 10,
            ),
          ],
        );
      },
    );
  }
}

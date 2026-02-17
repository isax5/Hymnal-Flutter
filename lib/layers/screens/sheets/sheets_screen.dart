import 'package:flutter/material.dart';
import 'package:hymnal_app/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/widgets/app_scaffold.dart';

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
        final l10n = AppLocalizations.of(context)!;
        return AppScaffold(
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
            title: Text(l10n.sheetMusicTitle(widget.hymnNumber)),
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
                                  Text(l10n.failedToLoadImage(error.toString())),
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
          playerBottomOffset: isLandscape ? 0 : 0,
        );
      },
    );
  }
}

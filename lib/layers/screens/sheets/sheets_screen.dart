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
          appBar: _buildAnimatedAppBar(context, l10n, isLandscape),
          showPlayer: _isPlayerBottomVisible,
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
                  : GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleAppBar,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: _isPlayerBottomVisible
                              ? MediaQuery.of(context).viewPadding.bottom
                              : 0,
                        ),
                        child: PhotoViewGallery.builder(
                          itemCount: _sheetUrls.length,
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: AssetImage(_sheetUrls[index]),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                              basePosition: Alignment.topCenter,
                              tightMode: true,
                              gestureDetectorBehavior: HitTestBehavior.translucent,
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
        );
      },
    );
  }

  PreferredSizeWidget? _buildAnimatedAppBar(
      BuildContext context, AppLocalizations l10n, bool isLandscape) {
    final appBarHeight = 56 + (isLandscape ? 40.0 : kToolbarHeight);

    return PreferredSize(
      preferredSize: Size.fromHeight(_isAppBarVisible ? appBarHeight : 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _isAppBarVisible ? appBarHeight : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isAppBarVisible ? 1.0 : 0.0,
          child: AppBar(
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
            toolbarHeight: appBarHeight,
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
        ),
      ),
    );
  }
}

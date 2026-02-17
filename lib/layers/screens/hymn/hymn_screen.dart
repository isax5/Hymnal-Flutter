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
import 'package:hymnal_app/widgets/app_scaffold.dart';

import 'package:hymnal_app/l10n/generated/app_localizations.dart';

part 'hymn_controller.dart';

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

class _HymnScreenState extends _HymnController {
  Widget _buildAudioButtons(bool hasInstrumental, bool hasSung) {
    final l10n = AppLocalizations.of(context)!;
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
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 0 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.piano, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            l10n.instrumental,
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
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 0 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.record_voice_over, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            l10n.sung,
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    final audioButtonsHeight = (isLandscape ? 30.0 : 30.0);
    // Only apply offset if bottomNavigationBar is showing
    final bottomOffset = hasAudio ? audioButtonsHeight : 0.0;

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
        title: Text(l10n.hymnTitle(_hymn!.number)),
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
      bottomNavigationBar: hasAudio ? _buildAudioButtons(hasInstrumental, hasSung) : null,
      playerBottomOffset: bottomOffset,
    );
  }

  Widget _buildHymnContent(Hymn hymn) {
    return AnimatedBuilder(
      animation: _settingsService,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
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
                '${_hymnal?.name}',
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
        );
      },
    );
  }
}

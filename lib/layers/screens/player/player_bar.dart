import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hymnal_app/core/constants/layout_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/audio_service.dart';

class PlayerBar extends StatelessWidget {
  final VoidCallback? onTap;
  final double bottomPadding;

  const PlayerBar({
    super.key,
    this.onTap,
    this.bottomPadding = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = GetIt.I<AudioService>();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final barHeight =
        isLandscape ? LayoutConstants.playerBarHeightLandscape : LayoutConstants.playerBarHeight;

    return AnimatedBuilder(
      animation: audioService,
      builder: (context, child) {
        if (audioService.currentHymn == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(maxHeight: barHeight, minHeight: barHeight),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: isLandscape ? 4 : 8,
                    bottom: (isLandscape ? 4 : 8) + bottomPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#${audioService.currentHymn!.number} • ${audioService.currentHymn!.title}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLandscape ? 12 : 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              audioService.currentHymnal!.name,
                              style: TextStyle(
                                fontSize: isLandscape ? 10 : 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: isLandscape ? 20 : 24,
                        icon: Icon(
                          audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        ),
                        onPressed: () => audioService.togglePlayPause(),
                      ),
                      IconButton(
                        iconSize: isLandscape ? 20 : 24,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => audioService.stop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

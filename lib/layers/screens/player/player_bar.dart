import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/layers/screens/player/player_screen.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = GetIt.I<AudioService>();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return AnimatedBuilder(
      animation: audioService,
      builder: (context, child) {
        if (audioService.currentHymn == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/player'),
                builder: (_) => const PlayerScreen(),
              ),
            );
          },
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isLandscape ? 4 : 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            audioService.currentHymn!.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isLandscape ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '#${audioService.currentHymn!.number}',
                            style: TextStyle(
                              fontSize: isLandscape ? 10 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: isLandscape ? 20 : 24,
                      icon: Icon(
                        audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () => audioService.togglePlayPause(),
                    ),
                    IconButton(
                      iconSize: isLandscape ? 20 : 24,
                      icon: const Icon(Icons.close),
                      onPressed: () => audioService.stop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

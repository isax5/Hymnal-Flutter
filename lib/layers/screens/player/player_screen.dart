import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class PlayerScreen extends StatelessWidget {
  final bool showBackground;
  final VoidCallback? onClose;
  const PlayerScreen({super.key, this.showBackground = true, this.onClose});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _openHymnPage(BuildContext context, String hymnalId, int hymnNumber) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/hymn'),
        builder: (_) => HymnScreen(
          hymnalId: hymnalId,
          hymnNumber: hymnNumber,
          skipHistory: true,
        ),
      ),
      (route) {
        return route.settings.name != '/hymn' && route.settings.name != '/player';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = GetIt.I<AudioService>();
    final settingsService = GetIt.I<SettingsService>();

    final content = Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: onClose != null
              ? IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  onPressed: onClose,
                )
              : null,
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
          title: const Text('Now Playing'),
        ),
        body: AnimatedBuilder(
          animation: audioService,
          builder: (context, child) {
            final hymn = audioService.currentHymn;
            final hymnal = audioService.currentHymnal;

            if (hymn == null) {
              return const Center(
                child: Text('No audio playing'),
              );
            }

            final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

            final albumArt = Container(
              width: isLandscape ? 180 : 220,
              height: isLandscape ? 180 : 220,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                audioService.isInstrumental ? Icons.piano : Icons.record_voice_over,
                size: isLandscape ? 60 : 80,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            );

            final hymnInfo = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hymn.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 18 : null,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '#${hymn.number} • ${hymnal?.name ?? ""}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: isLandscape ? 14 : null,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    audioService.isInstrumental ? 'Instrumental' : 'Sung',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );

            final controls = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: audioService.position.inMilliseconds.toDouble().clamp(
                        0,
                        audioService.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      ),
                  max: audioService.duration.inMilliseconds.toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                  onChanged: (value) {
                    audioService.seek(
                      Duration(milliseconds: value.toInt()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioService.position),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(audioService.duration),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: isLandscape ? 32 : 42,
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () => audioService.skipPrevious(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded),
                      iconSize: isLandscape ? 24 : 32,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      onPressed: () {
                        audioService.seek(
                          audioService.position - const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => audioService.togglePlayPause(),
                      child: Container(
                        width: isLandscape ? 56 : 72,
                        height: isLandscape ? 56 : 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: isLandscape ? 32 : 42,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded),
                      iconSize: isLandscape ? 24 : 32,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      onPressed: () {
                        audioService.seek(
                          audioService.position + const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: isLandscape ? 32 : 42,
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () => audioService.skipNext(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => audioService.toggleContinuousPlay(),
                      icon: Icon(
                        Icons.playlist_play,
                        color: audioService.continuousPlay
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        size: isLandscape ? 18 : null,
                      ),
                      label: Text(
                        'Continuous Play',
                        style: TextStyle(
                          color: audioService.continuousPlay
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight:
                              audioService.continuousPlay ? FontWeight.bold : FontWeight.normal,
                          fontSize: isLandscape ? 11 : null,
                        ),
                      ),
                    ),
                    if (isLandscape) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (hymnal != null) {
                            _openHymnPage(context, hymnal.id, hymn.number);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.library_music, size: 18),
                        label: const Text('View Lyrics', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ],
            );

            if (isLandscape) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Row(
                  children: [
                    Center(child: albumArt),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          hymnInfo,
                          const SizedBox(height: 8),
                          controls,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  albumArt,
                  const SizedBox(height: 32),
                  hymnInfo,
                  const SizedBox(height: 48),
                  controls,
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (hymnal != null) {
                        _openHymnPage(context, hymnal.id, hymn.number);
                      }
                    },
                    icon: const Icon(Icons.library_music),
                    label: const Text('View Lyrics'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (!showBackground) return content;

    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, child) {
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
            content,
          ],
        );
      },
    );
  }
}

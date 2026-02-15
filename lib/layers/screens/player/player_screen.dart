import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _openHymnPage(BuildContext context, String hymnalId, int hymnNumber) {
    // Check if HymnScreen is already in the navigation stack
    // Use pushAndRemoveUntil to replace the current hymn/player stack with the new hymn.
    // This strictly removes any existing '/hymn' or '/player' routes from the top of the stack,
    // essentially "swapping" the current view for the new hymn lyrics, while preserving
    // the history (Home, Search, etc.) that effectively "launched" this flow.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/hymn'),
        builder: (_) => HymnScreen(
          hymnalId: hymnalId,
          hymnNumber: hymnNumber,
          skipHistory: true, // Don't add to history since it's from current playback
        ),
      ),
      (route) {
        // Keep routes that are NOT '/hymn' or '/player'.
        // This ensures check marks like "Home" or "Search" stay, but intermediate
        // player/hymn pages are removed, preventing a deep loop stack.
        return route.settings.name != '/hymn' && route.settings.name != '/player';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = GetIt.I<AudioService>();

    return Scaffold(
      appBar: AppBar(
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

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    audioService.isInstrumental ? Icons.piano : Icons.record_voice_over,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  hymn.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${hymnal?.name ?? ""} • #${hymn.number}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  audioService.isInstrumental ? 'Instrumental' : 'Sung',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
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
                      Text(_formatDuration(audioService.position)),
                      Text(_formatDuration(audioService.duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skip previous
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 36,
                      onPressed: () => audioService.skipPrevious(),
                    ),
                    const SizedBox(width: 8),
                    // Rewind 10s
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      iconSize: 36,
                      onPressed: () {
                        audioService.seek(
                          audioService.position - const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Play/Pause
                    FloatingActionButton(
                      onPressed: () => audioService.togglePlayPause(),
                      child: Icon(
                        audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Forward 10s
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      iconSize: 36,
                      onPressed: () {
                        audioService.seek(
                          audioService.position + const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Skip next
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 36,
                      onPressed: () => audioService.skipNext(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Continuous play toggle
                TextButton.icon(
                  onPressed: () => audioService.toggleContinuousPlay(),
                  icon: Icon(
                    Icons.playlist_play,
                    color: audioService.continuousPlay
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  label: Text(
                    'Continuous Play',
                    style: TextStyle(
                      color: audioService.continuousPlay
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      fontWeight: audioService.continuousPlay ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
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
    );
  }
}

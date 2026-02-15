import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Hymn? _currentHymn;
  Hymnal? _currentHymnal;
  String? _currentUrl;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isInstrumental = true;
  bool _continuousPlay = false;

  AudioPlayer get player => _player;
  Hymn? get currentHymn => _currentHymn;
  Hymnal? get currentHymnal => _currentHymnal;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isInstrumental => _isInstrumental;
  bool get hasAudio => _currentUrl != null;
  bool get continuousPlay => _continuousPlay;

  AudioService() {
    debugPrint('[AudioService] Initializing...');
    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        debugPrint('[AudioService] Duration updated: $duration');
        _duration = duration;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      debugPrint(
          '[AudioService] Player state changed: playing=${state.playing}, processingState=${state.processingState}');
      _isPlaying = state.playing;
      notifyListeners();

      // Auto-advance to next hymn when playback completes
      if (state.processingState == ProcessingState.completed && _continuousPlay) {
        debugPrint(
            '[AudioService] Playback completed, continuous play is ON — advancing to next hymn');
        skipNext();
      }
    });
    debugPrint('[AudioService] Initialized successfully');
  }

  void toggleContinuousPlay() {
    _continuousPlay = !_continuousPlay;
    debugPrint('[AudioService] Continuous play: $_continuousPlay');
    notifyListeners();
  }

  Future<void> skipNext() async {
    debugPrint('[AudioService] skipNext()');
    final nextHymn = await _getAdjacentHymn(1);
    if (nextHymn != null) {
      await _playAdjacentHymn(nextHymn);
    } else {
      debugPrint('[AudioService] No next hymn available');
    }
  }

  Future<void> skipPrevious() async {
    debugPrint('[AudioService] skipPrevious()');
    final prevHymn = await _getAdjacentHymn(-1);
    if (prevHymn != null) {
      await _playAdjacentHymn(prevHymn);
    } else {
      debugPrint('[AudioService] No previous hymn available');
    }
  }

  Future<Hymn?> _getAdjacentHymn(int offset) async {
    if (_currentHymn == null || _currentHymnal == null) return null;

    try {
      final repository = GetIt.I<HymnalRepository>();
      final hymns = await repository.getHymns(_currentHymnal!.id);
      final currentIndex = hymns.indexWhere((h) => h.number == _currentHymn!.number);

      if (currentIndex < 0) return null;

      final nextIndex = currentIndex + offset;
      if (nextIndex < 0 || nextIndex >= hymns.length) return null;

      return hymns[nextIndex];
    } catch (e) {
      debugPrint('[AudioService] Error getting adjacent hymn: $e');
      return null;
    }
  }

  Future<void> _playAdjacentHymn(Hymn hymn) async {
    if (_currentHymnal == null) return;

    try {
      final repository = GetIt.I<HymnalRepository>();
      final musicSettings = await repository.getMusicSettings(_currentHymnal!.id);

      String? url;
      if (_isInstrumental) {
        url = musicSettings?.getInstrumentalUrl(hymn.number);
      } else {
        url = musicSettings?.getSungUrl(hymn.number);
      }

      if (url != null) {
        debugPrint('[AudioService] Playing adjacent hymn: ${hymn.number} "${hymn.title}"');
        // Reset _currentUrl so playHymn doesn't treat it as a toggle
        _currentUrl = null;
        await playHymn(_currentHymnal!, hymn, url);
      } else {
        debugPrint(
            '[AudioService] No ${_isInstrumental ? "instrumental" : "sung"} URL for hymn ${hymn.number}');
      }
    } catch (e) {
      debugPrint('[AudioService] Error playing adjacent hymn: $e');
    }
  }

  Future<void> playHymn(Hymnal hymnal, Hymn hymn, String url, {bool? instrumental}) async {
    // Keep current instrumental setting if not explicitly provided
    final isInstrumental = instrumental ?? _isInstrumental;

    debugPrint(
        '[AudioService] playHymn called: hymn=${hymn.number} "${hymn.title}", hymnal=${hymnal.id}, instrumental=$isInstrumental');
    debugPrint('[AudioService] URL: $url');

    if (_currentUrl == url && _isPlaying) {
      debugPrint('[AudioService] Same URL already playing, pausing instead');
      await pause();
      return;
    }

    _isLoading = true;
    _currentHymn = hymn;
    _currentHymnal = hymnal;
    _currentUrl = url;
    _isInstrumental = isInstrumental;
    notifyListeners();

    try {
      debugPrint('[AudioService] Setting audio source...');
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );

      debugPrint('[AudioService] Audio source set, starting playback...');
      await _player.play();
      _isLoading = false;
      debugPrint('[AudioService] Playback started successfully');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _currentHymn = null;
      _currentHymnal = null;
      _currentUrl = null;
      notifyListeners();
      debugPrint('[AudioService] ERROR playing audio: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    debugPrint('[AudioService] play()');
    await _player.play();
  }

  Future<void> pause() async {
    debugPrint('[AudioService] pause()');
    await _player.pause();
  }

  Future<void> stop() async {
    debugPrint('[AudioService] stop()');
    await _player.stop();
    _currentHymn = null;
    _currentHymnal = null;
    _currentUrl = null;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    debugPrint('[AudioService] seek($position)');
    await _player.seek(position);
  }

  Future<void> togglePlayPause() async {
    debugPrint('[AudioService] togglePlayPause() — currently ${_isPlaying ? "playing" : "paused"}');
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  void dispose() {
    debugPrint('[AudioService] dispose()');
    _player.dispose();
    super.dispose();
  }
}

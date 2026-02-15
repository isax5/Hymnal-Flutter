import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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

  AudioPlayer get player => _player;
  Hymn? get currentHymn => _currentHymn;
  Hymnal? get currentHymnal => _currentHymnal;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isInstrumental => _isInstrumental;
  bool get hasAudio => _currentUrl != null;

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
    });
    debugPrint('[AudioService] Initialized successfully');
  }

  Future<void> playHymn(Hymn hymn, Hymnal hymnal, String url, {bool instrumental = true}) async {
    debugPrint(
        '[AudioService] playHymn called: hymn=${hymn.number} "${hymn.title}", hymnal=${hymnal.id}, instrumental=$instrumental');
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
    _isInstrumental = instrumental;
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

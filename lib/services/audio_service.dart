import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> playHymn(Hymn hymn, Hymnal hymnal, String url,
      {bool instrumental = true}) async {
    if (_currentUrl == url && _isPlaying) {
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
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '${hymnal.id}_${hymn.number}',
            title: hymn.title,
            artist: hymnal.name,
            artUri: Uri.parse('asset:///assets/app_icon.png'),
          ),
        ),
      );

      await _player.play();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentHymn = null;
    _currentHymnal = null;
    _currentUrl = null;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/data/repository/settings_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';

class SettingsService extends ChangeNotifier {
  final HymnalRepository _hymnalRepository = GetIt.I<HymnalRepository>();
  final SettingsRepository _settingsRepository = GetIt.I<SettingsRepository>();

  List<Hymnal> _hymnals = [];
  Hymnal? _selectedHymnal;
  double _fontSize = 16.0;
  String _themeMode = 'system';
  bool _keepScreenOn = false;
  bool _showBackgroundImage = true;
  bool _isLoading = true;

  List<Hymnal> get hymnals => _hymnals;
  Hymnal? get selectedHymnal => _selectedHymnal;
  double get fontSize => _fontSize;
  String get themeMode => _themeMode;
  bool get keepScreenOn => _keepScreenOn;
  bool get showBackgroundImage => _showBackgroundImage;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _hymnals = await _hymnalRepository.getHymnals();

    final savedHymnalId = await _settingsRepository.getSelectedHymnalId();
    if (savedHymnalId != null) {
      _selectedHymnal = _hymnals.firstWhere(
        (h) => h.id == savedHymnalId,
        orElse: () => _hymnals.first,
      );
    } else {
      _selectedHymnal = _hymnals.first;
    }

    _fontSize = await _settingsRepository.getFontSize();
    _themeMode = await _settingsRepository.getThemeMode();
    _keepScreenOn = await _settingsRepository.getKeepScreenOn();
    _showBackgroundImage = await _settingsRepository.getShowBackgroundImage();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectHymnal(String hymnalId) async {
    _selectedHymnal = _hymnals.firstWhere((h) => h.id == hymnalId);
    await _settingsRepository.setSelectedHymnalId(hymnalId);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _settingsRepository.setFontSize(size);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _settingsRepository.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    await _settingsRepository.setKeepScreenOn(value);
    notifyListeners();
  }

  Future<void> setShowBackgroundImage(bool value) async {
    _showBackgroundImage = value;
    await _settingsRepository.setShowBackgroundImage(value);
    notifyListeners();
  }

  List<Hymnal> getHymnalsByLanguage(String languageCode) {
    return _hymnals
        .where((h) => h.twoLetterIsoLanguageName == languageCode)
        .toList();
  }
}

import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/data/repository/favorites_repository.dart';
import 'package:hymnal_app/layers/data/repository/history_repository.dart';
import 'package:hymnal_app/layers/data/repository/settings_repository.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/services/audio_service.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Repositories
  getIt.registerLazySingleton<HymnalRepository>(() => HymnalRepositoryImpl());
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl());
  getIt.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl());
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepository());

  // Services
  getIt.registerLazySingleton<SettingsService>(() => SettingsService());
  getIt.registerLazySingleton<FavoritesService>(() => FavoritesService());
  getIt.registerLazySingleton<HistoryService>(() => HistoryService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
}

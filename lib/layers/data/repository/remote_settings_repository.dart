import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hymnal_app/constants/app_links.dart';
import 'package:hymnal_app/layers/domain/model/music_settings.dart';

/// Repository responsible for fetching, parsing, and caching
/// remote music settings (settings.json) in RAM.
///
/// Settings are loaded once per session from the remote URL.
/// On failure the in-memory cache is returned when available;
/// otherwise the error propagates so callers can degrade gracefully.
class RemoteSettingsRepository {
  List<MusicSettings>? _cachedSettings;
  bool _isFetching = false;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches settings from the remote URL.
  ///
  /// If the settings are already cached and [force] is false,
  /// returns the cached copy without a network call.
  /// On network failure, returns the cache if available; otherwise rethrows.
  Future<List<MusicSettings>> fetchSettings({bool force = false}) async {
    // Return cached data unless a refresh is forced.
    if (_cachedSettings != null && !force) return _cachedSettings!;

    // Avoid duplicate concurrent fetches.
    if (_isFetching && _cachedSettings != null) return _cachedSettings!;

    _isFetching = true;
    try {
      // Use ResponseType.plain to receive the raw JSON string, then decode
      // manually. This avoids any ambiguity in how Dio handles generic types.
      final response = await _dio.get<String>(
        AppLinks.settingsUrl,
        options: Options(responseType: ResponseType.plain),
      );
      debugPrint('[RemoteSettingsRepository] Response status: ${response.statusCode}');
      final String rawBody = response.data ?? '';
      if (rawBody.isEmpty) throw Exception('Empty response body');
      final List<dynamic> jsonList = jsonDecode(rawBody) as List<dynamic>;
      _cachedSettings =
          jsonList.map((e) => MusicSettings.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedSettings!;
    } catch (e) {
      debugPrint('[RemoteSettingsRepository] Fetch failed: $e');
      // If we have stale data, return it silently.
      if (_cachedSettings != null) return _cachedSettings!;
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  /// Returns the cached settings list, or `null` if never fetched.
  List<MusicSettings>? getCachedSettings() => _cachedSettings;

  /// Looks up settings for a specific hymnal from the cache.
  /// Returns `null` if the cache is empty or the hymnal is not found.
  MusicSettings? getMusicSettingsForHymnal(String hymnalId) {
    if (_cachedSettings == null) return null;
    final settings = _cachedSettings!.cast<MusicSettings?>().firstWhere(
          (s) => s?.id == hymnalId,
          orElse: () => null,
        );
    return settings;
  }
}

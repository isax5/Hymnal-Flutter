import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/layers/domain/model/music_settings.dart';

abstract class HymnalRepository {
  Future<List<Hymnal>> getHymnals();
  Future<List<Hymn>> getHymns(String hymnalId);
  Future<List<ThematicCategory>> getThematicList(String hymnalId);
  Future<MusicSettings?> getMusicSettings(String hymnalId);
  Future<Hymn?> getHymnByNumber(String hymnalId, int number);
  Future<List<Hymn>> searchHymns(String hymnalId, String query);
}

class HymnalRepositoryImpl implements HymnalRepository {
  List<Hymnal>? _cachedHymnals;
  final Map<String, List<Hymn>> _cachedHymns = {};
  final Map<String, List<ThematicCategory>> _cachedThematicLists = {};
  final Map<String, MusicSettings> _cachedMusicSettings = {};

  @override
  Future<List<Hymnal>> getHymnals() async {
    if (_cachedHymnals != null) return _cachedHymnals!;

    final jsonString = await rootBundle.loadString('info_constants.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _cachedHymnals = jsonList.map((e) => Hymnal.fromJson(e)).toList();
    return _cachedHymnals!;
  }

  @override
  Future<List<Hymn>> getHymns(String hymnalId) async {
    if (_cachedHymns.containsKey(hymnalId)) return _cachedHymns[hymnalId]!;

    final hymnals = await getHymnals();
    final hymnal = hymnals.firstWhere((h) => h.id == hymnalId);

    final jsonString = await rootBundle.loadString('assets/hymns/${hymnal.hymnsFileName}');
    final List<dynamic> jsonList = json.decode(jsonString);
    final hymns = jsonList.map((e) => Hymn.fromJson(e)).toList();

    _cachedHymns[hymnalId] = hymns;
    return hymns;
  }

  @override
  Future<List<ThematicCategory>> getThematicList(String hymnalId) async {
    if (_cachedThematicLists.containsKey(hymnalId)) {
      return _cachedThematicLists[hymnalId]!;
    }

    final hymnals = await getHymnals();
    final hymnal = hymnals.firstWhere((h) => h.id == hymnalId);

    final jsonString = await rootBundle.loadString('assets/hymns/${hymnal.thematicHymnsFileName}');
    final List<dynamic> jsonList = json.decode(jsonString);
    final thematicList = jsonList.map((e) => ThematicCategory.fromJson(e)).toList();

    _cachedThematicLists[hymnalId] = thematicList;
    return thematicList;
  }

  @override
  Future<MusicSettings?> getMusicSettings(String hymnalId) async {
    if (_cachedMusicSettings.containsKey(hymnalId)) {
      return _cachedMusicSettings[hymnalId];
    }

    final jsonString = await rootBundle.loadString('settings.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final settings = jsonList.map((e) => MusicSettings.fromJson(e)).toList();

    final musicSetting = settings.cast<MusicSettings?>().firstWhere(
          (s) => s?.id == hymnalId,
          orElse: () => null,
        );

    if (musicSetting != null) {
      _cachedMusicSettings[hymnalId] = musicSetting;
    }

    return musicSetting;
  }

  @override
  Future<Hymn?> getHymnByNumber(String hymnalId, int number) async {
    final hymns = await getHymns(hymnalId);
    try {
      return hymns.firstWhere((h) => h.number == number);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Hymn>> searchHymns(String hymnalId, String query) async {
    final hymns = await getHymns(hymnalId);
    final lowerQuery = query.toLowerCase();

    return hymns.where((hymn) {
      return hymn.title.toLowerCase().contains(lowerQuery) ||
          hymn.content.toLowerCase().contains(lowerQuery) ||
          hymn.number.toString().contains(lowerQuery);
    }).toList();
  }
}

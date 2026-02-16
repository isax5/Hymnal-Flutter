import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymnal_app/layers/domain/model/hymn_history_entry.dart';
import 'package:hymnal_app/constants/app_constants.dart';

abstract class HistoryRepository {
  Future<List<HymnHistoryEntry>> getHistory();
  Future<void> addToHistory(HymnHistoryEntry entry);
  Future<void> clearHistory();
}

class HistoryRepositoryImpl implements HistoryRepository {
  static const String _historyKey = 'history';

  @override
  Future<List<HymnHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => HymnHistoryEntry.fromJson(e)).toList();
  }

  @override
  Future<void> addToHistory(HymnHistoryEntry entry) async {
    var history = await getHistory();

    history.removeWhere(
      (h) => h.hymnalId == entry.hymnalId && h.hymnNumber == entry.hymnNumber,
    );

    history.insert(0, entry);

    if (history.length > AppConstants.maxHistoryItems) {
      history = history.sublist(0, AppConstants.maxHistoryItems);
    }

    await _saveHistory(history);
  }

  @override
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _saveHistory(List<HymnHistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }
}

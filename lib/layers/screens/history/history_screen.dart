import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = GetIt.I<HistoryService>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  @override
  void initState() {
    super.initState();
    _historyService.loadHistory();
  }

  Future<void> _openHymn(String hymnalId, int hymnNumber, String title) async {
    await _historyService.addToHistory(hymnalId, hymnNumber, title);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HymnScreen(
            hymnalId: hymnalId,
            hymnNumber: hymnNumber,
          ),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _historyService,
      builder: (context, child) {
        final history = _historyService.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearHistory,
                ),
            ],
          ),
          body: history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No history yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${entry.hymnNumber}'),
                      ),
                      title: Text(entry.title),
                      subtitle: Text(
                        '${_getHymnalName(entry.hymnalId)} • ${_formatDate(entry.openedAt)}',
                      ),
                      onTap: () => _openHymn(
                        entry.hymnalId,
                        entry.hymnNumber,
                        entry.title,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  String _getHymnalName(String hymnalId) {
    final hymnal = _settingsService.hymnals.firstWhere(
      (h) => h.id == hymnalId,
      orElse: () => _settingsService.hymnals.first,
    );
    return hymnal.name;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class AmbitScreen extends StatelessWidget {
  final String category;
  final Ambit ambit;
  final List<Hymn> hymns;

  const AmbitScreen({
    super.key,
    required this.category,
    required this.ambit,
    required this.hymns,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ambit.name),
      ),
      body: ListView.builder(
        itemCount: hymns.length,
        itemBuilder: (context, index) {
          final hymn = hymns[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${hymn.number}'),
            ),
            title: Text(hymn.title),
            onTap: () async {
              final settingsService = GetIt.I<SettingsService>();
              final historyService = GetIt.I<HistoryService>();

              await historyService.addToHistory(
                settingsService.selectedHymnal!.id,
                hymn.number,
                hymn.title,
              );

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/hymn'),
                    builder: (_) => HymnScreen(
                      hymnalId: settingsService.selectedHymnal!.id,
                      hymnNumber: hymn.number,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

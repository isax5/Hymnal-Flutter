import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';

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
    final settingsService = GetIt.I<SettingsService>();
    final historyService = GetIt.I<HistoryService>();

    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            if (settingsService.showBackgroundImage)
              Positioned.fill(
                child: Image.asset(
                  'assets/background_image.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.15),
                ),
              ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                toolbarHeight:
                    MediaQuery.of(context).orientation == Orientation.landscape ? 40 : null,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                titleTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                title: Text(category),
              ),
              body: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: hymns.length,
                itemBuilder: (context, index) {
                  final hymn = hymns[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
                      child: Text(
                        '${hymn.number}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(hymn.title),
                    onTap: () async {
                      await historyService.addToHistory(
                          settingsService.selectedHymnal!.id, hymn.number, hymn.title);
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
            ),
            const DraggablePlayer(
              includeSafeArea: false,
              bottomPadding: 20,
            ),
          ],
        );
      },
    );
  }
}

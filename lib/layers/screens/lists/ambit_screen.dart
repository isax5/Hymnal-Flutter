import 'package:hymnal_app/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';

part 'ambit_controller.dart';

class AmbitScreen extends StatefulWidget {
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
  State<AmbitScreen> createState() => _AmbitScreenState();
}

class _AmbitScreenState extends _AmbitController {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsService,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            if (_settingsService.showBackgroundImage)
              Positioned.fill(
                child: Image.asset(
                  AppAssets.backgroundImage,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.15),
                ),
              ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                toolbarHeight:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 40
                        : null,
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
                title: Text(widget.category),
              ),
              body: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: widget.hymns.length,
                itemBuilder: (context, index) {
                  final hymn = widget.hymns[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.6),
                      child: Text(
                        '${hymn.number}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(hymn.title),
                    onTap: () => _onHymnTapped(hymn),
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

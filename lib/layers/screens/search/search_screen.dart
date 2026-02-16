import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';

part 'search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends _SearchController {
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
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search hymns...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              body: Column(
                children: [
                  if (_isLoading) const LinearProgressIndicator(),
                  Expanded(
                    child: _results.isEmpty
                        ? const Center(child: Text('No hymns found'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final hymn = _results[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.6),
                                  child: Text(
                                    '${hymn.number}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(hymn.title),
                                subtitle: Text(
                                  hymn.content.replaceAll('\n', ' ').substring(
                                      0, hymn.content.length > 100 ? 100 : hymn.content.length),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _openHymn(hymn),
                              );
                            },
                          ),
                  ),
                ],
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

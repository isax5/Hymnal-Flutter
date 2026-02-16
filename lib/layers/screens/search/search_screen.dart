import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/widgets/app_scaffold.dart';
import 'package:hymnal_app/widgets/hymn_list_tile.dart';

import 'package:hymnal_app/l10n/generated/app_localizations.dart';

part 'search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends _SearchController {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).orientation == Orientation.landscape ? 40 : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
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
                ? Center(child: Text(l10n.noHymnsFound))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final hymn = _results[index];
                      return HymnListTile(
                        number: hymn.number,
                        title: hymn.title,
                        subtitle: hymn.content
                            .replaceAll('\n', ' ')
                            .substring(0, hymn.content.length > 100 ? 100 : hymn.content.length),
                        onTap: () => _openHymn(hymn),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

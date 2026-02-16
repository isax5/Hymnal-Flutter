import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/layers/screens/lists/ambit_screen.dart';

import 'package:hymnal_app/l10n/app_localizations.dart';

part 'lists_controller.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends _ListsController {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.numeric, icon: const Icon(Icons.format_list_numbered)),
              Tab(text: l10n.alpha, icon: const Icon(Icons.sort_by_alpha)),
              Tab(text: l10n.thematic, icon: const Icon(Icons.category)),
            ],
          ),
        ),
        body: _hymns == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildNumericList(),
                  _buildAlphabeticList(),
                  _buildThematicList(),
                ],
              ),
      ),
    );
  }

  Widget _buildNumericList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _hymns!.length,
      itemBuilder: (context, index) {
        final hymn = _hymns![index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
            child: Text(
              '${hymn.number}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(hymn.title),
          onTap: () => _openHymn(hymn),
        );
      },
    );
  }

  Widget _buildAlphabeticList() {
    final sortedHymns = List<Hymn>.from(_hymns!)..sort((a, b) => a.title.compareTo(b.title));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedHymns.length,
      itemBuilder: (context, index) {
        final hymn = sortedHymns[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
            child: Text(
              '${hymn.number}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(hymn.title),
          onTap: () => _openHymn(hymn),
        );
      },
    );
  }

  Widget _buildThematicList() {
    if (_thematicList == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _thematicList!.length,
      itemBuilder: (context, index) {
        final category = _thematicList![index];
        return ExpansionTile(
          title: Text(
            category.thematic,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: category.ambits.map((ambit) {
            return ListTile(
              dense: true,
              title: Text(ambit.name),
              subtitle: Text(AppLocalizations.of(context)!.hymnRange(ambit.start, ambit.end)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AmbitScreen(
                    category: category.thematic,
                    ambit: ambit,
                    hymns: _hymns!
                        .where((h) => h.number >= ambit.start && h.number <= ambit.end)
                        .toList(),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

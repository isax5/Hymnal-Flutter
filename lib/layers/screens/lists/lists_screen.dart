import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/layers/domain/model/thematic_category.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';
import 'package:hymnal_app/layers/screens/lists/ambit_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();

  List<Hymn>? _hymns;
  List<ThematicCategory>? _thematicList;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) return;

    final hymns = await _repository.getHymns(hymnal.id);
    final thematic = await _repository.getThematicList(hymnal.id);

    setState(() {
      _hymns = hymns;
      _thematicList = thematic;
    });
  }

  Future<void> _openHymn(Hymn hymn) async {
    final hymnal = _settingsService.selectedHymnal!;
    await _historyService.addToHistory(hymnal.id, hymn.number, hymn.title);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HymnScreen(
            hymnalId: hymnal.id,
            hymnNumber: hymn.number,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lists'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: const [
              Tab(text: 'Numeric', icon: Icon(Icons.format_list_numbered)),
              Tab(text: 'Alphabetic', icon: Icon(Icons.sort_by_alpha)),
              Tab(text: 'Thematic', icon: Icon(Icons.category)),
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
      itemCount: _hymns!.length,
      itemBuilder: (context, index) {
        final hymn = _hymns![index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${hymn.number}'),
          ),
          title: Text(hymn.title),
          onTap: () => _openHymn(hymn),
        );
      },
    );
  }

  Widget _buildAlphabeticList() {
    final sortedHymns = List<Hymn>.from(_hymns!)
      ..sort((a, b) => a.title.compareTo(b.title));

    return ListView.builder(
      itemCount: sortedHymns.length,
      itemBuilder: (context, index) {
        final hymn = sortedHymns[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${hymn.number}'),
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
              subtitle: Text('Hymns ${ambit.start}-${ambit.end}'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AmbitScreen(
                    category: category.thematic,
                    ambit: ambit,
                    hymns: _hymns!
                        .where((h) =>
                            h.number >= ambit.start && h.number <= ambit.end)
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

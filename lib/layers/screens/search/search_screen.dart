import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/domain/model/hymn.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final HymnalRepository _repository = GetIt.I<HymnalRepository>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final HistoryService _historyService = GetIt.I<HistoryService>();

  List<Hymn> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Focus the search field and load all hymns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      _loadAllHymns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAllHymns() async {
    setState(() => _isLoading = true);

    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) {
      setState(() => _isLoading = false);
      return;
    }

    final hymns = await _repository.getHymns(hymnal.id);

    setState(() {
      _results = hymns;
      _isLoading = false;
    });
  }

  Future<void> _search(String query) async {
    final hymnal = _settingsService.selectedHymnal;
    if (hymnal == null) return;

    if (query.isEmpty) {
      // Show all hymns when search is empty
      final hymns = await _repository.getHymns(hymnal.id);
      setState(() {
        _results = hymns;
      });
      return;
    }

    setState(() => _isLoading = true);

    final results = await _repository.searchHymns(hymnal.id, query);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Future<void> _openHymn(Hymn hymn) async {
    final hymnal = _settingsService.selectedHymnal!;
    await _historyService.addToHistory(hymnal.id, hymn.number, hymn.title);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/hymn'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hymns'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter title, lyrics, or number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No hymns found'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final hymn = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${hymn.number}'),
                        ),
                        title: Text(hymn.title),
                        subtitle: Text(
                          hymn.content.replaceAll('\n', ' ').substring(
                              0,
                              hymn.content.length > 100
                                  ? 100
                                  : hymn.content.length),
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
    );
  }
}

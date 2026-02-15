import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:hymnal_app/layers/data/repository/hymnal_repository.dart';
import 'package:hymnal_app/layers/screens/search/search_screen.dart';
import 'package:hymnal_app/layers/screens/history/history_screen.dart';
import 'package:hymnal_app/layers/screens/hymn/hymn_screen.dart';

part 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends _HomeController {
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
            GestureDetector(
              onTap: _unfocusKeyboard,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  title: const Text('Hymnal'),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_settingsService.selectedHymnal != null)
                          Card(
                            elevation: 4,
                            child: InkWell(
                              onTap: _showHymnalSelector,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _settingsService.selectedHymnal!.name,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          Text(
                                            '${_settingsService.selectedHymnal!.year} • ${_settingsService.selectedHymnal!.detail}',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, size: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _numberController,
                                  focusNode: _numberFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Hymn Number',
                                    hintText: 'Enter hymn number',
                                    prefixIcon: const Icon(Icons.music_note),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _openHymn,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open Hymn'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _unfocusKeyboard();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                                  );
                                },
                                icon: const Icon(Icons.search),
                                label: const Text('Search'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _unfocusKeyboard();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                                  );
                                },
                                icon: const Icon(Icons.history),
                                label: const Text('History'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

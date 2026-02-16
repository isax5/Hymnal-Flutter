import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:hymnal_app/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = GetIt.I<SettingsService>();
  final FavoritesService _favoritesService = GetIt.I<FavoritesService>();

  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _favoritesService.loadFavorites();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_settingsService]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).orientation == Orientation.landscape ? 40 : null,
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
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildSection('Hymnal'),
              _buildHymnalSelector(),
              _buildSection('Appearance'),
              _buildThemeSelector(),
              _buildFontSizeSlider(),
              SwitchListTile(
                title: const Text('Background Image'),
                subtitle: const Text('Show background image on screens'),
                value: _settingsService.showBackgroundImage,
                onChanged: (value) => _settingsService.setShowBackgroundImage(value),
              ),
              _buildSection('Behavior'),
              _buildSwitchTile(
                'Keep Screen On',
                _settingsService.keepScreenOn,
                (value) {
                  _settingsService.setKeepScreenOn(value);
                  WakelockPlus.toggle(enable: value);
                },
              ),
              _buildSection('Data Management'),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Clear History'),
                subtitle: const Text('Remove all recently viewed hymns'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text(
                        'Are you sure you want to clear your history? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await GetIt.I<HistoryService>().clearHistory();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('History cleared'),
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear Favorites'),
                subtitle: const Text('Remove all favorite hymns'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Favorites'),
                      content: const Text(
                        'Are you sure you want to clear all favorites? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await _favoritesService.clearFavorites();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorites cleared'),
                        ),
                      );
                    }
                  }
                },
              ),
              _buildSection('About'),
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('Website'),
                subtitle: const Text(AppConstants.websiteUrl),
                onTap: () => _launchUrl(AppConstants.websiteUrl),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Contribute'),
                subtitle: const Text('GitHub Repository'),
                onTap: () => _launchUrl(AppConstants.repositoryUrl),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate the App'),
                onTap: _showRateOptions,
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: Text('$_appVersion ($_buildNumber)'),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Licenses'),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHymnalSelector() {
    return ListTile(
      leading: const Icon(Icons.book),
      title: const Text('Selected Hymnal'),
      subtitle: Text(_settingsService.selectedHymnal != null
          ? '${_settingsService.selectedHymnal?.name} • ${_settingsService.selectedHymnal?.detail}'
          : 'None'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showHymnalSelector,
    );
  }

  Widget _buildThemeSelector() {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text(_capitalize(_settingsService.themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showThemeSelector,
    );
  }

  Widget _buildFontSizeSlider() {
    return ListTile(
      leading: const Icon(Icons.format_size),
      title: const Text('Font Size'),
      subtitle: Slider(
        value: _settingsService.fontSize,
        min: 12,
        max: 32,
        divisions: 10,
        label: _settingsService.fontSize.round().toString(),
        onChanged: (value) => _settingsService.setFontSize(value),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: const Icon(Icons.settings),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _showHymnalSelector() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Hymnal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._settingsService.hymnals.map((hymnal) {
              final isSelected = hymnal.id == _settingsService.selectedHymnal?.id;
              return ListTile(
                leading: Text(
                  hymnal.twoLetterIsoLanguageName.toUpperCase(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                title: Text(hymnal.name),
                subtitle: Text('${hymnal.year} • ${hymnal.detail}'),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  _settingsService.selectHymnal(hymnal.id);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemeSelector() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              trailing: _settingsService.themeMode == 'system' ? const Icon(Icons.check) : null,
              onTap: () {
                _settingsService.setThemeMode('system');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: _settingsService.themeMode == 'light' ? const Icon(Icons.check) : null,
              onTap: () {
                _settingsService.setThemeMode('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: _settingsService.themeMode == 'dark' ? const Icon(Icons.check) : null,
              onTap: () {
                _settingsService.setThemeMode('dark');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRateOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Rate the App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('App Store'),
              onTap: () {
                _launchUrl(AppConstants.appStoreUrl);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Play Store'),
              onTap: () {
                _launchUrl(AppConstants.playStoreUrl);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

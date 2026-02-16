import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/favorites_service.dart';
import 'package:hymnal_app/services/history_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:hymnal_app/constants/app_constants.dart';

part 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends _SettingsController {
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
                onTap: _clearHistory,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear Favorites'),
                subtitle: const Text('Remove all favorite hymns'),
                onTap: _clearFavorites,
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/core/constants/app_assets.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/layers/screens/player/draggable_player.dart';
import 'package:hymnal_app/core/constants/layout_constants.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool showPlayer;
  final double playerBottomOffset;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.showPlayer = true,
    this.playerBottomOffset = 0.0,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<DraggablePlayerState> _playerKey = GlobalKey<DraggablePlayerState>();

  @override
  Widget build(BuildContext context) {
    final settingsService = GetIt.I<SettingsService>();
    final audioService = GetIt.I<AudioService>();

    return AnimatedBuilder(
      animation: Listenable.merge([settingsService, audioService]),
      builder: (context, child) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final playerHeight = isLandscape
            ? LayoutConstants.playerBarHeightLandscape
            : LayoutConstants.playerBarHeight;
        final hasActivePlayer = widget.showPlayer && audioService.currentHymn != null;
        final theme = Theme.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: theme.appBarTheme.systemOverlayStyle ??
              (theme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark),
          child: Stack(
            children: [
              Container(color: Theme.of(context).scaffoldBackgroundColor),
              if (settingsService.showBackgroundImage)
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.backgroundImage,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.15),
                  ),
                ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: widget.appBar,
                body: widget.body,
                bottomNavigationBar: (widget.bottomNavigationBar == null && !hasActivePlayer)
                    ? null
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasActivePlayer) SizedBox(height: playerHeight),
                          if (widget.bottomNavigationBar != null) widget.bottomNavigationBar!,
                        ],
                      ),
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              ),
              if (hasActivePlayer)
                DraggablePlayer(
                  key: _playerKey,
                  includeSafeArea: true,
                  bottomOffset: widget.playerBottomOffset,
                ),
            ],
          ),
        );
      },
    );
  }
}

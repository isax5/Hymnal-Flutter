import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/layers/screens/player/player_bar.dart';
import 'package:hymnal_app/layers/screens/player/player_screen.dart';

class DraggablePlayer extends StatefulWidget {
  final double bottomOffset;
  final bool includeSafeArea;
  final double bottomPadding;

  const DraggablePlayer({
    super.key,
    this.bottomOffset = 0.0,
    this.includeSafeArea = true,
    this.bottomPadding = 0.0,
  });

  @override
  State<DraggablePlayer> createState() => _DraggablePlayerState();
}

class _DraggablePlayerState extends State<DraggablePlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_controller.isAnimating) return;

    final velocity = details.primaryVelocity!;
    if (velocity < -500) {
      _controller.forward();
    } else if (velocity > 500) {
      _controller.reverse();
    } else if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = GetIt.I<AudioService>();
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom =
        widget.includeSafeArea ? MediaQuery.of(context).padding.bottom : 0.0;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Use shorter height and ignore bottomPadding in landscape to prevent gaps
    final baseMinHeight = isLandscape ? 45.0 : 72.0;
    final effectiveMinHeight = baseMinHeight + widget.bottomPadding;

    // Total bottom offset including safety and nav bar
    final effectiveBottomOffset = widget.bottomOffset + safeAreaBottom;

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, audioService]),
      builder: (context, child) {
        if (audioService.currentHymn == null) {
          return const SizedBox.shrink();
        }

        final expansionValue = _controller.value;

        // When expansionValue is 0, we want bottom = effectiveBottomOffset
        // When expansionValue is 1, we want bottom = 0
        final currentBottom = effectiveBottomOffset * (1.0 - expansionValue);

        // Height expands from effectiveMinHeight to full screenHeight
        final currentHeight = effectiveMinHeight +
            (screenHeight - effectiveMinHeight) * expansionValue;

        return Positioned(
          left: 0,
          right: 0,
          bottom: currentBottom,
          height: currentHeight,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (_controller.isAnimating) return;
              final delta = -details.primaryDelta! /
                  (screenHeight - effectiveMinHeight - widget.bottomOffset);
              _controller.value += delta;
            },
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Stack(
              children: [
                // Solid background that fades in
                Opacity(
                  opacity: expansionValue,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                // Full Player Screen
                Opacity(
                  opacity: expansionValue,
                  child: IgnorePointer(
                    ignoring: expansionValue < 0.5,
                    child: PlayerScreen(
                      showBackground: false,
                      onClose: () => _controller.reverse(),
                    ),
                  ),
                ),
                // Mini Player Bar
                Opacity(
                  opacity: 1.0 - expansionValue,
                  child: IgnorePointer(
                    ignoring: expansionValue > 0.5,
                    child: PlayerBar(
                      onTap: () => _controller.forward(),
                      bottomPadding: isLandscape ? 10.0 : widget.bottomPadding,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

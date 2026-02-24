import 'package:flutter/material.dart';
import 'package:hymnal_app/core/constants/layout_constants.dart';
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
  State<DraggablePlayer> createState() => DraggablePlayerState();
}

class DraggablePlayerState extends State<DraggablePlayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void expand() => _controller.forward();
  void collapse() => _controller.reverse();

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
    final safeAreaBottom = widget.includeSafeArea ? MediaQuery.of(context).padding.bottom : 0.0;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Use shorter height in landscape
    final baseMinHeight =
        isLandscape ? LayoutConstants.playerBarHeightLandscape : LayoutConstants.playerBarHeight;
    final effectiveMinHeight = baseMinHeight + widget.bottomPadding;

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, audioService]),
      builder: (context, child) {
        if (audioService.currentHymn == null) {
          return const SizedBox.shrink();
        }

        final expansionValue = _controller.value;

        // Total bottom offset including nav bar.
        // We use safeAreaBottom if includeSafeArea is true.
        final currentBottom = (widget.bottomOffset + safeAreaBottom) * (1.0 - expansionValue);

        // Height expands from effectiveMinHeight to full screenHeight
        final currentHeight =
            effectiveMinHeight + (screenHeight - effectiveMinHeight) * expansionValue;

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
                  opacity: expansionValue.clamp(0.0, 1.0),
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                // Full Player Screen
                Opacity(
                  opacity: expansionValue.clamp(0.0, 1.0),
                  child: IgnorePointer(
                    ignoring: expansionValue < 0.1, // Show early during drag
                    child: PlayerScreen(
                      showBackground: false,
                      onClose: () => _controller.reverse(),
                    ),
                  ),
                ),
                // Mini Player Bar (only visible while dragging, Fades out quickly)
                if (expansionValue < 0.5)
                  Opacity(
                    opacity: (1.0 - expansionValue * 2).clamp(0.0, 1.0),
                    child: PlayerBar(
                      onTap: () => _controller.forward(),
                      bottomPadding: isLandscape ? 10.0 : widget.bottomPadding,
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

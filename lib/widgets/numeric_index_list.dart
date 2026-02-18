import 'package:flutter/material.dart';

class NumericIndexBar extends StatefulWidget {
  final int itemCount;
  final int interval;
  final ScrollController scrollController;
  final double itemHeight;

  const NumericIndexBar({
    super.key,
    required this.itemCount,
    required this.interval,
    required this.scrollController,
    this.itemHeight = 72,
  });

  @override
  State<NumericIndexBar> createState() => _NumericIndexBarState();
}

class _NumericIndexBarState extends State<NumericIndexBar> {
  int? _selectedIndex;

  List<int> get _indices {
    final List<int> result = [];
    final interval = widget.interval;

    if (interval <= 1) {
      for (int i = 0; i < widget.itemCount; i += 1) {
        result.add(i);
      }
    } else {
      int k = 0;
      while (true) {
        final int i = k == 0 ? 0 : k * interval - 1;
        if (i >= widget.itemCount) break;
        result.add(i);
        k++;
      }
    }

    if (result.isEmpty || result.last < widget.itemCount - 1) {
      result.add(widget.itemCount - 1);
    }

    return result;
  }

  void _scrollToIndex(int index) {
    final targetOffset = index * widget.itemHeight;
    final maxOffset = widget.scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxOffset);
    widget.scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _handleTouch(details.localPosition.dy);
      },
      onVerticalDragUpdate: (details) {
        _handleTouch(details.localPosition.dy);
      },
      onTapDown: (details) {
        _handleTouch(details.localPosition.dy);
      },
      child: Container(
        width: 24,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _indices.map((index) {
            final number = index + 1;
            return Expanded(
              child: GestureDetector(
                onTap: () => _scrollToIndex(index),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleTouch(double dy) {
    final totalHeight = context.size?.height ?? 200;
    final indexCount = _indices.length;
    if (indexCount == 0) return;

    final selectedPosition = (dy / totalHeight * indexCount).clamp(0, indexCount - 1).toInt();
    final selectedIndex = _indices[selectedPosition];

    if (_selectedIndex != selectedIndex) {
      setState(() => _selectedIndex = selectedIndex);
      _scrollToIndex(selectedIndex);
    }
  }
}

class NumericIndexListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int jumpInterval;
  final double itemHeight;
  final EdgeInsets padding;

  const NumericIndexListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.jumpInterval = 50,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.only(bottom: 80),
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: padding,
            itemCount: itemCount,
            itemExtent: itemHeight,
            itemBuilder: itemBuilder,
          ),
        ),
        NumericIndexBar(
          itemCount: itemCount,
          interval: jumpInterval,
          scrollController: scrollController,
          itemHeight: itemHeight,
        ),
      ],
    );
  }
}

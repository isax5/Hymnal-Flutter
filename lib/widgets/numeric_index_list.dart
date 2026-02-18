import 'package:flutter/material.dart';

class NumericIndexBar extends StatefulWidget {
  final int itemCount;
  final int interval;
  final ScrollController scrollController;
  final double itemHeight;
  final double headerHeight;
  final ValueChanged<String?>? onIndexChanged;

  const NumericIndexBar({
    super.key,
    required this.itemCount,
    required this.interval,
    required this.scrollController,
    this.itemHeight = 72,
    this.headerHeight = 32,
    this.onIndexChanged,
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
    final headersBefore = _indices.where((h) => h < index).length;
    final targetOffset = index * widget.itemHeight + headersBefore * widget.headerHeight;
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
      onVerticalDragEnd: (_) {
        if (widget.onIndexChanged != null) widget.onIndexChanged!(null);
      },
      onVerticalDragCancel: () {
        if (widget.onIndexChanged != null) widget.onIndexChanged!(null);
      },
      onTapDown: (details) {
        _handleTouch(details.localPosition.dy);
      },
      onTapUp: (_) {
        if (widget.onIndexChanged != null) widget.onIndexChanged!(null);
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
                onTap: () {
                  setState(() => _selectedIndex = index);
                  final number = (index + 1).toString();
                  if (widget.onIndexChanged != null) widget.onIndexChanged!(number);
                  _scrollToIndex(index);
                  // Ensure the hint is dismissed after a short delay when tapping
                  if (widget.onIndexChanged != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) widget.onIndexChanged!(null);
                    });
                  }
                },
                // This item nedded this container with any color and any margin to the child to make the touch area bigger and more comfortable to use
                child: Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.symmetric(vertical: 5),
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

    final pos = (dy / totalHeight * indexCount).clamp(0.0, (indexCount - 1).toDouble());
    final selectedPosition = pos.round().clamp(0, indexCount - 1);
    final selectedIndex = _indices[selectedPosition];

    if (_selectedIndex != selectedIndex) {
      setState(() => _selectedIndex = selectedIndex);
      final number = (selectedIndex + 1).toString();
      if (widget.onIndexChanged != null) widget.onIndexChanged!(number);
      _scrollToIndex(selectedIndex);
    }
  }
}

class NumericIndexListView extends StatefulWidget {
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
  State<NumericIndexListView> createState() => _NumericIndexListViewState();
}

class _NumericIndexListViewState extends State<NumericIndexListView> {
  String? _hint;

  List<int> get _indices {
    final List<int> result = [];
    final interval = widget.jumpInterval;

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

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    const headerHeight = 32.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: widget.padding,
                itemCount: widget.itemCount,
                itemBuilder: (context, index) {
                  final hymnWidget = widget.itemBuilder(context, index);
                  if (_indices.contains(index)) {
                    final label = (index + 1).toString();
                    final header = Container(
                      height: headerHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [header, SizedBox(height: widget.itemHeight, child: hymnWidget)],
                    );
                  }
                  return SizedBox(height: widget.itemHeight, child: hymnWidget);
                },
              ),
            ),
            NumericIndexBar(
              itemCount: widget.itemCount,
              interval: widget.jumpInterval,
              scrollController: scrollController,
              itemHeight: widget.itemHeight,
              headerHeight: headerHeight,
              onIndexChanged: (val) {
                setState(() => _hint = val);
              },
            ),
          ],
        ),
        if (_hint != null)
          AnimatedOpacity(
            opacity: _hint != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Text(
                _hint!,
                style:
                    const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

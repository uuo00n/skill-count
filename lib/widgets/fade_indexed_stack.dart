import 'package:flutter/material.dart';

/// A Stack that shows a single child at a time with a fade transition.
/// 
/// Unlike [AnimatedSwitcher], this widget keeps all children in the tree
/// (preserving their state) and uses [AnimatedOpacity] to hide/show them.
/// This is similar to [IndexedStack] but with animation.
class FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: children.asMap().entries.map((entry) {
        final i = entry.key;
        final child = entry.value;
        final isActive = i == index;

        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: duration,
            curve: curve,
            child: child,
          ),
        );
      }).toList(),
    );
  }
}

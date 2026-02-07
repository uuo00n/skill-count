import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// WorldSkills isometric cube pattern background with slow scrolling animation
class GridBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;

  const GridBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  State<GridBackground> createState() => _GridBackgroundState();
}

class _GridBackgroundState extends State<GridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Exact dimensions from SVG viewBox
  static const _tileW = 778.022;
  static const _tileH = 745.523;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svgTile = SvgPicture.asset(
      'assets/images/P24.svg',
      width: _tileW,
      height: _tileH,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: widget.showGrid ? 0.15 : 0.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols =
                    (constraints.maxWidth / _tileW).ceil() + 2;
                final rows =
                    (constraints.maxHeight / _tileH).ceil() + 2;

                return ClipRect(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final dx = _controller.value * _tileW;
                      final dy = _controller.value * _tileH;

                      return Stack(
                        children: [
                          for (int r = -1; r < rows; r++)
                            for (int c = -1; c < cols; c++)
                              Positioned(
                                left: c * _tileW - dx,
                                top: r * _tileH - dy,
                                width: _tileW,
                                height: _tileH,
                                child: svgTile,
                              ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

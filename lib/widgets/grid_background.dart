import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// WorldSkills isometric cube pattern background
class GridBackground extends StatelessWidget {
  final Widget child;

  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Tile the SVG pattern to fill the screen
                const tileWidth = 778.0;
                const tileHeight = 745.0;
                final cols =
                    (constraints.maxWidth / tileWidth).ceil() + 1;
                final rows =
                    (constraints.maxHeight / tileHeight).ceil() + 1;

                return ClipRect(
                  child: Stack(
                    children: [
                      for (int r = 0; r < rows; r++)
                        for (int c = 0; c < cols; c++)
                          Positioned(
                            left: c * tileWidth,
                            top: r * tileHeight,
                            width: tileWidth,
                            height: tileHeight,
                            child: SvgPicture.asset(
                              'assets/images/P24.svg',
                              fit: BoxFit.none,
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        child,
      ],
    );
  }
}

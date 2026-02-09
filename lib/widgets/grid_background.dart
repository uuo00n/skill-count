import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// WorldSkills honeycomb pattern background with seamless scrolling animation
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
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    // 120s loop for very slow diagonal scrolling
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(GridBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showGrid != oldWidget.showGrid) {
      if (widget.showGrid) {
        _resolveImage();
        if (!_controller.isAnimating) _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  void _resolveImage() {
    if (!widget.showGrid) return;

    final ImageProvider provider = const AssetImage(
        'assets/images/Patterns_sample_honeycomb_teal.png');
    final ImageStream newStream =
        provider.resolve(createLocalImageConfiguration(context));
    if (newStream.key != _imageStream?.key) {
      _imageStream?.removeListener(ImageStreamListener(_handleImageInfo));
      _imageStream = newStream;
      _imageStream!.addListener(ImageStreamListener(_handleImageInfo));
    }
  }

  void _handleImageInfo(ImageInfo info, bool synchronousCall) {
    if (mounted) {
      setState(() {
        _imageInfo = info;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageStream?.removeListener(ImageStreamListener(_handleImageInfo));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.showGrid && _imageInfo != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PatternPainter(
                    image: _imageInfo!.image,
                    scrollProgress: _controller.value,
                    scale: _imageInfo!.scale,
                  ),
                );
              },
            ),
          ),
        // Add Blur and overlay for better legibility
        if (widget.showGrid)
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final ui.Image image;
  final double scrollProgress;
  final double scale;

  _PatternPainter({
    required this.image,
    required this.scrollProgress,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate logical size of the image considering high-DPI scaling
    final double displayScale = scale;
    final double imgW = image.width.toDouble() / displayScale;
    final double imgH = image.height.toDouble() / displayScale;

    // Use a small negative spacing (overlap) to hide seams
    const double overlap = 0.5; // Overlap by 0.5 logical pixels

    // Calculate effective tile size
    final double tileW = imgW - overlap;
    final double tileH = imgH - overlap;

    // Calculate offset based on scroll progress (0 to -tileW)
    final double dx = -(scrollProgress * tileW);
    final double dy = -(scrollProgress * tileH);

    // Calculate number of columns/rows needed to cover the screen
    // We add extra columns/rows to ensure coverage when shifting
    // (size.width / tileW) gives visible tiles. 
    // We add +2 to cover partial tiles on both edges.
    final int cols = (size.width / tileW).ceil() + 2;
    final int rows = (size.height / tileH).ceil() + 2;

    final Paint paint = Paint();

    // Loop through grid. 
    // We start from -1 to ensure we cover the left/top edge when shifting.
    // dx/dy shifts everything left/up by up to 1 tile width/height.
    // So tile at index 0 will move from 0 to -tileW.
    // Tile at index -1 will move from -tileW to -2*tileW.
    // We need to ensure right/bottom edges are covered.
    for (int col = -1; col < cols; col++) {
      for (int row = -1; row < rows; row++) {
        final double x = dx + col * tileW;
        final double y = dy + row * tileH;

        // Skip drawing if completely off-screen (optimization)
        if (x + tileW < 0 || x > size.width || 
            y + tileH < 0 || y > size.height) {
          continue;
        }

        // Reset matrix for each tile
        canvas.save();
        canvas.translate(x, y);
        canvas.scale(1 / displayScale); // Scale down the image content

        canvas.drawImage(image, Offset.zero, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.scrollProgress != scrollProgress ||
        oldDelegate.image != image;
  }
}

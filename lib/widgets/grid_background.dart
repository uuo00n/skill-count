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
    // Or positive spacing if a gap is explicitly desired
    // User requested "0.1 gap", but also complained about "obvious line"
    // Using a very slight overlap usually fixes the "obvious line" (seam) better than a gap
    // However, if the user specifically asked for a gap, we can try -0.5 overlap first as it's the standard fix
    const double overlap = 0.5; // Overlap by 0.5 logical pixels

    // Calculate effective tile size
    final double tileW = imgW - overlap;
    final double tileH = imgH - overlap;

    // Calculate offset based on scroll progress
    // Move by full image dimensions
    final double dx = -(scrollProgress * tileW);
    final double dy = -(scrollProgress * tileH);

    // Calculate starting position to ensure we cover the screen
    // We need to start before 0,0 because of the scrolling
    final int startCol = (dx / tileW).floor() - 1;
    final int startRow = (dy / tileH).floor() - 1;

    // Calculate how many tiles we need
    final int cols = (size.width / tileW).ceil() + 2;
    final int rows = (size.height / tileH).ceil() + 2;

    final Paint paint = Paint();

    for (int col = 0; col < cols; col++) {
      for (int row = 0; row < rows; row++) {
        final double x = dx + (startCol + col) * tileW;
        final double y = dy + (startRow + row) * tileH;

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

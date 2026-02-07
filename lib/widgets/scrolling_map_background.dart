import 'package:flutter/material.dart';

class ScrollingMapBackground extends StatefulWidget {
  final String imagePath;
  final Duration duration;
  final double opacity;

  const ScrollingMapBackground({
    super.key,
    required this.imagePath,
    this.duration = const Duration(seconds: 40),
    this.opacity = 0.15,
  });

  @override
  State<ScrollingMapBackground> createState() => _ScrollingMapBackgroundState();
}

class _ScrollingMapBackgroundState extends State<ScrollingMapBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Image 1
              Positioned(
                left: -_controller.value * MediaQuery.of(context).size.width,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              // Image 2 (follows Image 1)
              Positioned(
                left: (1 - _controller.value) * MediaQuery.of(context).size.width,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

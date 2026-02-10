import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/ws_colors.dart';

class WsFlipDigit extends StatefulWidget {
  final int value;
  final TextStyle textStyle;
  final Duration duration;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;

  const WsFlipDigit({
    super.key,
    required this.value,
    required this.textStyle,
    this.duration = const Duration(milliseconds: 400),
    this.width = 40,
    this.height = 60,
    this.backgroundColor = Colors.white,
    this.borderColor = WsColors.border,
  });

  @override
  State<WsFlipDigit> createState() => _WsFlipDigitState();
}

class _WsFlipDigitState extends State<WsFlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;
  int _nextValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentValue = _nextValue;
          _controller.reset();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant WsFlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _nextValue = widget.value;
      if (_controller.isAnimating) {
        _currentValue = _nextValue;
        _controller.reset();
      }
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating && _currentValue == _nextValue) {
      return _buildFullDigit(_currentValue);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 背景层
          Column(
            children: [
              Expanded(child: _buildHalfDigit(_nextValue, true)),
              Expanded(child: _buildHalfDigit(_currentValue, false)),
            ],
          ),
          
          // 2. 翻转层
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * math.pi;
              final isFront = angle < (math.pi / 2);

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.006)
                  ..rotateX(angle),
                alignment: Alignment.center,
                child: isFront
                    ? _buildHalfDigit(_currentValue, true)
                    : Transform(
                        transform: Matrix4.identity()..rotateX(math.pi),
                        alignment: Alignment.center,
                        child: _buildHalfDigit(_nextValue, false),
                      ),
              );
            },
          ),
          
          // 分割线
          Center(
            child: Container(
              height: 1,
              color: Colors.black.withAlpha(20),
              width: widget.width,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDigit(int value) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: widget.borderColor.withAlpha(50)),
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: widget.textStyle,
      ),
    );
  }

  Widget _buildHalfDigit(int value, bool isTop) {
    return ClipRect(
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: 1.0,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: isTop ? const Radius.circular(4) : Radius.zero,
              bottom: isTop ? Radius.zero : const Radius.circular(4),
            ),
            border: Border.all(color: widget.borderColor.withAlpha(50)),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: widget.textStyle,
          ),
        ),
      ),
    );
  }
}

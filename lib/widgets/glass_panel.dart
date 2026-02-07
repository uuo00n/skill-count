import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/ws_colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: WsColors.bgPanel.withAlpha(180),
            border: Border.all(
              color: WsColors.textSecondary.withAlpha(30),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

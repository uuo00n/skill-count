import 'package:flutter/material.dart';
import '../core/constants/ws_colors.dart';
import 'ws_flip_digit.dart';

/// 翻牌时钟风格的时间数字卡片，每位数字独立滚动动画
class WsTimerText extends StatelessWidget {
  final int value;
  final String label;

  const WsTimerText({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tens = value ~/ 10;
    final ones = value % 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: WsColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WsColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WsFlipDigit(
                value: tens,
                width: 42,
                height: 64,
                textStyle: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: WsColors.darkBlue,
                  height: 1.0,
                ),
                backgroundColor: WsColors.surface,
                borderColor: Colors.transparent,
              ),
              const SizedBox(width: 2),
              WsFlipDigit(
                value: ones,
                width: 42,
                height: 64,
                textStyle: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: WsColors.darkBlue,
                  height: 1.0,
                ),
                backgroundColor: WsColors.surface,
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: WsColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

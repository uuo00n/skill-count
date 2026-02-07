import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';

/// 翻牌时钟风格的时间数字卡片
class WsTimerText extends StatelessWidget {
  final String value;
  final String label;

  const WsTimerText({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: WsColors.bgDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1e3a5f),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: WsColors.white,
              letterSpacing: 2,
              height: 1.1,
            ),
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

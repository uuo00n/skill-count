import 'package:flutter/material.dart';

import '../../../core/constants/ws_colors.dart';
import '../../../core/i18n/locale_provider.dart';

class ModuleDeleteDialog extends StatelessWidget {
  final String moduleName;
  final int taskCount;
  final VoidCallback onConfirm;

  const ModuleDeleteDialog({
    super.key,
    required this.moduleName,
    required this.taskCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return AlertDialog(
      backgroundColor: WsColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WsColors.errorRed.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              size: 24,
              color: WsColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.confirmDeleteModule,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${s.deleteModuleWarning}: "$moduleName" ($taskCount tasks)',
            style: const TextStyle(
              fontSize: 13,
              color: WsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            s.cancel,
            style: const TextStyle(
              color: WsColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: WsColors.errorRed,
            foregroundColor: WsColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            s.confirmDelete,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

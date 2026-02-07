import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'module_model.dart';

class ModuleListPanel extends StatelessWidget {
  final List<ModuleModel> modules;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ModuleListPanel({
    super.key,
    required this.modules,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.view_module, size: 16, color: WsColors.accentBlue),
            const SizedBox(width: 8),
            Text(
              s.moduleTimerTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WsColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: modules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final module = modules[index];
              final isSelected = index == selectedIndex;
              return _buildModuleCard(context, module, isSelected, () {
                onSelect(index);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    ModuleModel module,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final s = LocaleScope.of(context);

    String statusLabel;
    Color statusColor;
    switch (module.status) {
      case ModuleStatus.completed:
        statusLabel = s.completed;
        statusColor = WsColors.accentGreen;
      case ModuleStatus.inProgress:
        statusLabel = s.inProgress;
        statusColor = WsColors.accentYellow;
      case ModuleStatus.upcoming:
        statusLabel = s.upcoming;
        statusColor = WsColors.textSecondary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? WsColors.accentBlue.withAlpha(20)
                : WsColors.bgDeep.withAlpha(180),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? WsColors.accentBlue.withAlpha(80)
                  : const Color(0xFF1e3a5f),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: WsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${module.duration.inHours}h ${module.duration.inMinutes % 60}m',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'JetBrainsMono',
                        color: WsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: WsColors.accentBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_analysis_history_service.dart';
import '../../core/ai/ai_providers.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/i18n/strings.dart';
import '../../core/providers/practice_history_provider.dart';
import '../../core/providers/time_providers.dart';
import '../practice_history/practice_history_service.dart';
import '../timezone/timezone_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final provider = LocaleScope.providerOf(context);
    final targetTime = ref.watch(competitionCountdownProvider).toLocal();
    final selectedTz = ref.watch(appTimezoneProvider);
    final selectedCity = TimeZoneCity.cities.firstWhere(
      (c) => c.timezoneId == selectedTz,
      orElse: () => TimeZoneCity.cities.first,
    );
    final offsetSign = selectedCity.utcOffset >= 0 ? '+' : '';
    final tzDisplay =
        '${selectedCity.name} (UTC$offsetSign${selectedCity.utcOffset})';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.settings.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WsColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingTile(
                icon: Icons.timer_outlined,
                title: s.competitionCountdown,
                subtitle: '${s.countdownTarget}  ${_formatDateTime(targetTime)}',
                trailing: TextButton(
                  onPressed: () => _selectCountdownTarget(
                    context,
                    ref,
                    ref.read(competitionCountdownProvider),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: WsColors.accentCyan,
                  ),
                  child: Text(
                    s.setCountdown,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.language,
                title: s.language,
                trailing: _buildLanguageDropdown(
                  provider.locale,
                  provider.locales,
                  (locale) => provider.setLocale(locale),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.public_outlined,
                title: s.displayTimezone,
                subtitle: tzDisplay,
                onTap: () => _showTimezoneDialog(context, ref, s, selectedTz),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: s.about,
                subtitle: s.aboutDescription,
                onTap: () => _showAppInfoDialog(context, s),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.verified_outlined,
                title: s.version,
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: WsColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.delete_outline,
                title: s.clearRecords,
                subtitle: s.clearRecordsDesc,
                onTap: () => _confirmClearRecords(context, ref, s),
                iconColor: WsColors.accentRed,
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.auto_delete_outlined,
                title: s.clearAIHistory,
                subtitle: s.clearAIHistoryDesc,
                onTap: () => _confirmClearAIHistory(context, ref, s),
                iconColor: WsColors.accentRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? body,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WsColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WsColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? WsColors.accentCyan),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WsColors.textPrimary,
                      ),
                    ),
                    if (body != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: body,
                      )
                    else if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: WsColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAppInfoDialog(BuildContext context, AppStrings s) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: WsColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: WsColors.accentCyan.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: WsColors.accentCyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      s.about,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: WsColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoLine(s.appTitle, 'v1.0.0'),
                const SizedBox(height: 8),
                _buildInfoLine(s.about, s.aboutDescription),
                const SizedBox(height: 8),
                _buildInfoLine('Author', 'HuangJunBo'),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: WsColors.accentCyan,
                    ),
                    child: Text(
                      s.close,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoLine(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: WsColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(
    AppLocale currentLocale,
    List<LocaleOption> locales,
    ValueChanged<AppLocale> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: WsColors.bgDeep.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: WsColors.textSecondary.withAlpha(40),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppLocale>(
          value: currentLocale,
          dropdownColor: WsColors.surface,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: WsColors.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: WsColors.textPrimary,
          ),
          onChanged: (value) {
            if (value == null) return;
            onChanged(value);
          },
          items: locales
              .map(
                (option) => DropdownMenuItem<AppLocale>(
                  value: option.locale,
                  child: Text(option.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _selectCountdownTarget(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current.toLocal(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (!context.mounted) return;

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.toLocal()),
    );

    if (!context.mounted) return;

    if (pickedTime == null) return;

    final localDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    ref.read(competitionCountdownProvider.notifier).state =
        localDateTime.toUtc();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimezoneDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
    String currentTz,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: WsColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: WsColors.accentCyan.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.public_outlined,
                        size: 20,
                        color: WsColors.accentCyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      s.selectTimezone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: WsColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...TimeZoneCity.cities.map(
                  (city) {
                    final isSelected = city.timezoneId == currentTz;
                    final sign = city.utcOffset >= 0 ? '+' : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            ref.read(appTimezoneProvider.notifier).state =
                                city.timezoneId;
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? WsColors.accentCyan.withAlpha(15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? WsColors.accentCyan
                                    : WsColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${city.name}  (UTC$sign${city.utcOffset})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? WsColors.accentCyan
                                          : WsColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: WsColors.accentCyan,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClearRecords(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final confirmed = await _showConfirmDialog(
      context,
      s,
      icon: Icons.delete_outline,
      title: s.clearRecords,
      message: s.clearRecordsWarning,
    );
    if (confirmed != true || !context.mounted) return;

    final service = PracticeHistoryService();
    await service.initialize();
    await service.clearAllRecords();
    ref.invalidate(practiceRecordsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.dataCleared),
          behavior: SnackBarBehavior.floating,
          backgroundColor: WsColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _confirmClearAIHistory(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final confirmed = await _showConfirmDialog(
      context,
      s,
      icon: Icons.auto_delete_outlined,
      title: s.clearAIHistory,
      message: s.clearAIHistoryWarning,
    );
    if (confirmed != true || !context.mounted) return;

    final historyService = AIAnalysisHistoryService();
    await historyService.initialize();
    await historyService.clearAll();
    ref.invalidate(aiAnalysisHistoryProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.dataCleared),
          behavior: SnackBarBehavior.floating,
          backgroundColor: WsColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    AppStrings s, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: WsColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WsColors.accentRed.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: WsColors.accentRed),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WsColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: WsColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: WsColors.textSecondary,
                    ),
                    child: Text(
                      s.cancel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WsColors.accentRed,
                      foregroundColor: WsColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      s.confirmDelete,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

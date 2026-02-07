import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/providers/time_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LocaleScope.of(context);
    final provider = LocaleScope.providerOf(context);
    final targetTime = ref.watch(competitionCountdownProvider).toLocal();

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
                  context,
                  provider.isChinese,
                  (isChinese) => provider.setLocale(isChinese),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: s.about,
                subtitle: s.aboutDescription,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WsColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: WsColors.accentCyan),
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
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    bool isChinese,
    ValueChanged<bool> onChanged,
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
        child: DropdownButton<bool>(
          value: isChinese,
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
          items: const [
            DropdownMenuItem<bool>(
              value: false,
              child: Text('EN'),
            ),
            DropdownMenuItem<bool>(
              value: true,
              child: Text('CN'),
            ),
          ],
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
}

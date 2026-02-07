import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);
    final provider = LocaleScope.providerOf(context);

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
              // Language setting
              _buildSettingTile(
                icon: Icons.language,
                title: s.language,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLangChip('EN', !provider.isChinese, () {
                      provider.setLocale(false);
                    }),
                    const SizedBox(width: 8),
                    _buildLangChip('CN', provider.isChinese, () {
                      provider.setLocale(true);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // About
              _buildSettingTile(
                icon: Icons.info_outline,
                title: s.about,
                subtitle: s.aboutDescription,
              ),
              const SizedBox(height: 12),
              // Version
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
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WsColors.bgPanel.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e3a5f)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: WsColors.accentBlue),
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
                if (subtitle != null)
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

  Widget _buildLangChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? WsColors.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? WsColors.accentBlue
                : WsColors.textSecondary.withAlpha(60),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? WsColors.white : WsColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

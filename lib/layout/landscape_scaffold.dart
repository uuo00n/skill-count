import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/ws_colors.dart';
import '../core/i18n/locale_provider.dart';
import '../core/providers/time_providers.dart';
import '../features/countdown/countdown_page.dart';
import '../features/settings/settings_page.dart';
import '../features/timezone/timezone_converter.dart';
import '../features/timezone/timezone_page.dart';
import '../features/unified_timer/widgets/unified_timer_page.dart';
import '../widgets/grid_background.dart';

class LandscapeScaffold extends ConsumerStatefulWidget {
  const LandscapeScaffold({super.key});

  @override
  ConsumerState<LandscapeScaffold> createState() => _LandscapeScaffoldState();
}

class _LandscapeScaffoldState extends ConsumerState<LandscapeScaffold> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    CountdownPage(),
    UnifiedTimerPage(),
    TimezonePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final s = LocaleScope.of(context);
    final provider = LocaleScope.providerOf(context);

    // 使用统一时间源 + IANA 时区
    final utcNow = ref.watch(unifiedTimeProvider);
    final shanghaiTime =
        TimezoneConverter.convert(utcNow, 'Asia/Shanghai');
    final hours = shanghaiTime.hour.toString().padLeft(2, '0');
    final minutes = shanghaiTime.minute.toString().padLeft(2, '0');
    final seconds = shanghaiTime.second.toString().padLeft(2, '0');

    String subtitle;
    switch (_selectedIndex) {
      case 0:
        subtitle = s.compTimerDashboard;
      case 1:
        subtitle = s.competitionSimulation;
      case 3:
        subtitle = s.settings.toUpperCase();
      default:
        subtitle = s.competitionSimulation;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: WsColors.surface,
        border: const Border(
          bottom: BorderSide(color: WsColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WsColors.accentCyan, width: 2),
            ),
            child: const Icon(
              Icons.hexagon_outlined,
              color: WsColors.accentCyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SkillCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WsColors.darkBlue,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: WsColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Real-time clock (Shanghai)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: WsColors.accentGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: WsColors.accentGreen.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: WsColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$hours:$minutes:$seconds',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: WsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Shanghai (UTC+8)',
            style: TextStyle(
              fontSize: 12,
              color: WsColors.textSecondary.withAlpha(180),
            ),
          ),
          const SizedBox(width: 16),
          // Language toggle
          _buildLangButton('EN', !provider.isChinese, () {
            provider.setLocale(false);
          }),
          const SizedBox(width: 4),
          _buildLangButton('CN', provider.isChinese, () {
            provider.setLocale(true);
          }),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? WsColors.accentCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive
                ? WsColors.accentCyan
                : WsColors.textSecondary.withAlpha(60),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? WsColors.white : WsColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final s = LocaleScope.of(context);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: WsColors.surface,
        border: const Border(
          top: BorderSide(color: WsColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavTab(0, Icons.dashboard_outlined, s.dashboard),
          const SizedBox(width: 8),
          ValueListenableBuilder<bool>(
            valueListenable: UnifiedTimerPage.isTimerRunning,
            builder: (context, isRunning, child) {
              return _buildNavTab(
                1,
                Icons.timer_outlined,
                s.unifiedTimer,
                showDot: isRunning,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildNavTab(2, Icons.public_outlined, s.timezone),
          const SizedBox(width: 8),
          // Settings icon
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedIndex = 3),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? WsColors.accentCyan.withAlpha(20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedIndex == 3
                      ? Border.all(color: WsColors.accentCyan.withAlpha(60))
                      : null,
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: _selectedIndex == 3
                      ? WsColors.accentCyan
                      : WsColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label,
      {bool showDot = false}) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedIndex = index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? WsColors.accentCyan.withAlpha(20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: WsColors.accentCyan.withAlpha(60))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? WsColors.accentCyan
                        : WsColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? WsColors.darkBlue
                          : WsColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showDot)
              Positioned(
                top: -2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: WsColors.accentGreen,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

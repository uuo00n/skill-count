import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/ws_colors.dart';
import '../core/i18n/locale_provider.dart';
import '../features/countdown/countdown_page.dart';
import '../features/module_timer/module_timer_page.dart';
import '../features/pomodoro/pomodoro_page.dart';
import '../features/settings/settings_page.dart';
import '../features/timezone/timezone_page.dart';
import '../widgets/competition_timeline.dart';
import '../widgets/grid_background.dart';

class LandscapeScaffold extends StatefulWidget {
  const LandscapeScaffold({super.key});

  @override
  State<LandscapeScaffold> createState() => _LandscapeScaffoldState();
}

class _LandscapeScaffoldState extends State<LandscapeScaffold> {
  int _selectedIndex = 0;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  static const _pages = <Widget>[
    CountdownPage(),
    PomodoroPage(),
    ModuleTimerPage(),
    TimezonePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _pages[_selectedIndex]),
            const CompetitionTimeline(),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final s = LocaleScope.of(context);
    final provider = LocaleScope.providerOf(context);
    final hours = _now.hour.toString().padLeft(2, '0');
    final minutes = _now.minute.toString().padLeft(2, '0');
    final seconds = _now.second.toString().padLeft(2, '0');

    String subtitle;
    switch (_selectedIndex) {
      case 0:
        subtitle = s.compTimerDashboard;
      case 1:
        subtitle = s.trainingMode;
      case 4:
        subtitle = s.settings.toUpperCase();
      default:
        subtitle = s.competitionSimulation;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: WsColors.bgDeep,
        border: Border(
          bottom: BorderSide(color: Color(0xFF1e3a5f), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WsColors.accentYellow, width: 2),
            ),
            child: const Icon(
              Icons.hexagon_outlined,
              color: WsColors.accentYellow,
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
                  color: WsColors.textPrimary,
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
          // Real-time clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: WsColors.accentGreen.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: WsColors.accentGreen.withAlpha(60),
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
          color: isActive ? WsColors.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive
                ? WsColors.accentBlue
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
      decoration: const BoxDecoration(
        color: WsColors.bgDeep,
        border: Border(
          top: BorderSide(color: Color(0xFF1e3a5f), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavTab(0, Icons.dashboard_outlined, s.dashboard),
          const SizedBox(width: 8),
          _buildNavTab(1, Icons.timer_outlined, s.skillPomodoro),
          const SizedBox(width: 8),
          _buildNavTab(2, Icons.view_module_outlined, s.moduleTimer),
          const SizedBox(width: 8),
          _buildNavTab(3, Icons.public_outlined, s.timezone),
          const SizedBox(width: 8),
          // Settings icon
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedIndex = 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 4
                      ? WsColors.darkBlue.withAlpha(180)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedIndex == 4
                      ? Border.all(color: WsColors.accentBlue.withAlpha(80))
                      : null,
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: _selectedIndex == 4
                      ? WsColors.accentYellow
                      : WsColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? WsColors.darkBlue.withAlpha(180)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: WsColors.accentBlue.withAlpha(80))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? WsColors.accentYellow
                    : WsColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? WsColors.textPrimary : WsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

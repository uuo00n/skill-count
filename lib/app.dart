import 'package:flutter/material.dart';
import 'core/i18n/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'layout/landscape_scaffold.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _localeProvider = LocaleProvider();

  @override
  void dispose() {
    _localeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      provider: _localeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkillCount',
        theme: AppTheme.light,
        locale: const Locale('zh'),
        home: const LandscapeScaffold(),
      ),
    );
  }
}

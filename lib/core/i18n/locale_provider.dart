import 'package:flutter/material.dart';
import 'strings.dart';
import 'zh.dart';
import 'en.dart';
import 'ja.dart';
import 'de.dart';
import 'fr.dart';
import 'ko.dart';

enum AppLocale { zh, en, ja, de, fr, ko }

class LocaleOption {
  final AppLocale locale;
  final String label;
  final String abbr;

  const LocaleOption(this.locale, this.label, this.abbr);
}

const supportedLocales = [
  LocaleOption(AppLocale.zh, 'CN 中文', 'CN'),
  LocaleOption(AppLocale.en, 'EN English', 'EN'),
  LocaleOption(AppLocale.ja, 'JA 日本語', 'JA'),
  LocaleOption(AppLocale.de, 'DE Deutsch', 'DE'),
  LocaleOption(AppLocale.fr, 'FR Français', 'FR'),
  LocaleOption(AppLocale.ko, 'KR 한국어', 'KR'),
];

/// Global locale notifier for language switching
class LocaleProvider extends ChangeNotifier {
  AppStrings _strings = const ZhStrings();
  AppLocale _locale = AppLocale.zh;

  AppStrings get strings => _strings;
  AppLocale get locale => _locale;
  List<LocaleOption> get locales => supportedLocales;
  String get currentAbbr =>
      supportedLocales.firstWhere((option) => option.locale == _locale).abbr;

  void setLocale(AppLocale locale) {
    _locale = locale;
    _strings = _stringsFor(locale);
    notifyListeners();
  }

  AppStrings _stringsFor(AppLocale locale) {
    switch (locale) {
      case AppLocale.zh:
        return const ZhStrings();
      case AppLocale.en:
        return const EnStrings();
      case AppLocale.ja:
        return const JaStrings();
      case AppLocale.de:
        return const DeStrings();
      case AppLocale.fr:
        return const FrStrings();
      case AppLocale.ko:
        return const KoStrings();
    }
  }
}

/// InheritedWidget to provide AppStrings down the widget tree
class LocaleScope extends InheritedNotifier<LocaleProvider> {
  const LocaleScope({
    super.key,
    required LocaleProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    return scope!.notifier!.strings;
  }

  static LocaleProvider providerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    return scope!.notifier!;
  }
}

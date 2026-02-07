import 'package:flutter/material.dart';
import 'strings.dart';
import 'zh.dart';
import 'en.dart';

/// Global locale notifier for language switching
class LocaleProvider extends ChangeNotifier {
  AppStrings _strings = const ZhStrings();
  bool _isChinese = true;

  AppStrings get strings => _strings;
  bool get isChinese => _isChinese;

  void setLocale(bool chinese) {
    _isChinese = chinese;
    _strings = chinese ? const ZhStrings() : const EnStrings();
    notifyListeners();
  }

  void toggle() => setLocale(!_isChinese);
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

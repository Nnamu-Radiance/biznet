// Create a simple ThemeProvider to manage light/dark mode
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const _boxName = 'authBox';
  static const _key = 'isDarkMode';

  bool _isDark = false;

  ThemeProvider() {
    _loadFromBox();
  }

  bool get isDarkMode => _isDark;

  void toggle() {
    _isDark = !_isDark;
    _saveToBox();
    notifyListeners();
  }

  Future<void> _loadFromBox() async {
    try {
      final box = Hive.box(_boxName);
      _isDark = box.get(_key, defaultValue: false) as bool;
      notifyListeners();
    } catch (_) {
      // ignore: avoid_print
      print('ThemeProvider: failed to load theme from box');
    }
  }

  Future<void> _saveToBox() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_key, _isDark);
    } catch (_) {
      // ignore: avoid_print
      print('ThemeProvider: failed to save theme to box');
    }
  }
}


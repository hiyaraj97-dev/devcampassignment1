import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Notifier managing light/dark theme preference and persistence.
class ThemeNotifier extends ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  ThemeNotifier(this._storageService) {
    _loadPreference();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isInitialized => _isInitialized;

  Future<void> _loadPreference() async {
    _isDarkMode = await _storageService.loadDarkMode();
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggles between Light and Dark mode, persisting the change.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveDarkMode(_isDarkMode);
  }

  /// Explicitly sets the theme mode.
  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    notifyListeners();
    await _storageService.saveDarkMode(_isDarkMode);
  }
}

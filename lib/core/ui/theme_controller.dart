import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists theme mode (light/dark/system) across app launches.
const _kThemePrefKey = 'vistar.themeMode';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kThemePrefKey);
      final restored = _decode(raw);
      if (restored != null && restored != state) {
        state = restored;
      }
    } catch (_) {
      // Keep default ThemeMode.system if storage is unavailable.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemePrefKey, _encode(mode));
    } catch (_) {
      // Ignore persistence errors — in-memory state is still updated.
    }
  }

  /// Cycle: system → light → dark → system.
  Future<void> cycle() async {
    switch (state) {
      case ThemeMode.system:
        await setMode(ThemeMode.light);
      case ThemeMode.light:
        await setMode(ThemeMode.dark);
      case ThemeMode.dark:
        await setMode(ThemeMode.system);
    }
  }

  /// Quick binary toggle (treats system as the platform's brightness).
  Future<void> toggle(Brightness platformBrightness) async {
    final current = state == ThemeMode.system
        ? (platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : state;
    await setMode(
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode? _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }
}

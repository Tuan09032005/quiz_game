import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A simple class to hold both gradient and its text color
class ThemeOption {
  final List<Color> colors;
  final Color textColor;

  const ThemeOption(this.colors, {this.textColor = Colors.white});
}

class ThemeHelper {
  // List of theme options. The first one is the default.
  static final List<ThemeOption> themes = [
    // New Default: Light Theme
    const ThemeOption([Color(0xFFF5F5F5), Color(0xFFE0E0E0)], textColor: Colors.black87),
    // Original Default Blue/Purple
    const ThemeOption([Color(0xFF6A11CB), Color(0xFF2575FC)]),
    // Pink/Red
    const ThemeOption([Color(0xFFF857A6), Color(0xFFFF5858)]),
    // Green/Yellow
    const ThemeOption([Color(0xFF16A085), Color(0xFFF4D03F)]),
    // Orange/Purple
    const ThemeOption([Color(0xFFD38312), Color(0xFFA83279)]),
    // Sky Blue
    const ThemeOption([Color(0xFF00c6ff), Color(0xFF0072ff)]),
  ];

  // Gets the currently selected theme option from storage
  static Future<ThemeOption> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_index') ?? 0;
    final safeIndex = index < themes.length ? index : 0;
    return themes[safeIndex];
  }

  // Gets the index of the current theme
  static Future<int> getCurrentThemeIndex() async {
     final prefs = await SharedPreferences.getInstance();
     final index = prefs.getInt('theme_index') ?? 0;
     return index < themes.length ? index : 0;
  }

  // Saves the user's theme choice
  static Future<void> setTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
  }
}

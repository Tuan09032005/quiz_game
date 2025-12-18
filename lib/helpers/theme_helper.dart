import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  // List of beautiful gradients for the user to choose from
  static final List<List<Color>> gradients = [
    [const Color(0xFF6A11CB), const Color(0xFF2575FC)], // Default Blue/Purple
    [const Color(0xFFF857A6), const Color(0xFFFF5858)], // Pink/Red
    [const Color(0xFF16A085), const Color(0xFFF4D03F)], // Green/Yellow
    [const Color(0xFFD38312), const Color(0xFFA83279)], // Orange/Purple
    [const Color(0xFF00c6ff), const Color(0xFF0072ff)], // Sky Blue
  ];

  // Gets the currently selected gradient from storage
  static Future<LinearGradient> getCurrentGradient() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_index') ?? 0;
    
    // Ensure index is within bounds
    final safeIndex = index < gradients.length ? index : 0;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradients[safeIndex],
    );
  }

  // Saves the user's theme choice
  static Future<void> setTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
  }
}

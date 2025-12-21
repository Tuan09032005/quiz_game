import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_game/services/audio_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'config/supabase_config.dart';

// Import các màn
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin/admin_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await AudioService.init();

  // Load sound effects setting
  final prefs = await SharedPreferences.getInstance();
  final soundEffectsEnabled = prefs.getBool('soundEffects') ?? true;
  AudioService.setSoundEffectsEnabled(soundEffectsEnabled);

  runApp(const QuizGameApp());
}

class QuizGameApp extends StatelessWidget {
  const QuizGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeManager(
      child: MaterialApp(
        title: "Quiz Game",
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/category': (context) => const CategoryScreen(),
          '/ranking': (context) => const RankingScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/admin': (context) => const AdminScreen(),
        },
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins', // Consider adding a modern font like Poppins
        ),
      ),
    );
  }
}

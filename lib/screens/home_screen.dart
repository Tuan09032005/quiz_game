import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    await AuthService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;

    if (isGuest) {
      return {'name': prefs.getString('userName') ?? 'Guest', 'is_admin': false, 'is_guest': true};
    }

    final user = AuthService.currentUser();
    if (user != null) {
      final profile = await AuthService.getProfileByAuthId(user.id);
      return {
        'name': profile?['name'] ?? 'User',
        'is_admin': profile?['is_admin'] == true,
        'is_guest': false,
      };
    }

    return {'name': 'Guest', 'is_admin': false, 'is_guest': true};
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              final isGuest = snapshot.data?['is_guest'] ?? true;
              if (isGuest) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.exit_to_app, color: themeProvider.textColor, size: 28),
                onPressed: _logout,
                tooltip: 'Logout',
              );
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: themeProvider.textColor,));
              }

              final userData = snapshot.data ?? {'name': 'Guest', 'is_admin': false, 'is_guest': true};
              final displayName = userData['name'];
              final isAdmin = userData['is_admin'];

              return _buildContent(displayName, isAdmin, themeProvider.textColor);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String displayName, bool isAdmin, Color textColor) {
    return Column(
      children: [
        _buildHeader(displayName, isAdmin, textColor),
        Expanded(
          child: _buildMenuGrid(isAdmin, textColor == Colors.black87),
        ),
      ],
    );
  }

  Widget _buildHeader(String displayName, bool isAdmin, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome,',
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 20),
          ),
          Text(
            displayName,
            style: TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'ADMIN',
                style: TextStyle(color: Colors.yellow[600], fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(bool isAdmin, bool isLightTheme) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _MenuItem(
          title: 'Play Quiz',
          icon: Icons.play_circle_fill_rounded,
          color: Colors.orangeAccent,
          isLightTheme: isLightTheme,
          onTap: () => Navigator.pushNamed(context, '/category'),
        ),
        _MenuItem(
          title: 'Ranking',
          icon: Icons.leaderboard_rounded,
          color: Colors.lightBlueAccent,
           isLightTheme: isLightTheme,
          onTap: () => Navigator.pushNamed(context, '/ranking'),
        ),
        _MenuItem(
          title: 'Profile',
          icon: Icons.person_rounded,
          color: Colors.greenAccent,
           isLightTheme: isLightTheme,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        _MenuItem(
          title: 'Settings',
          icon: Icons.settings_rounded,
          color: Colors.purpleAccent,
           isLightTheme: isLightTheme,
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        if (isAdmin)
          _MenuItem(
            title: 'Admin Panel',
            icon: Icons.admin_panel_settings_rounded,
            color: Colors.redAccent,
             isLightTheme: isLightTheme,
            onTap: () => Navigator.pushNamed(context, '/admin'),
          ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLightTheme;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLightTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.9);
    final textColor = isLightTheme ? Colors.black87 : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           isLightTheme
              ? BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)
              : BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

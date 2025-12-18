import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LinearGradient? _appGradient;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final gradient = await ThemeHelper.getCurrentGradient();
    if (mounted) {
      setState(() {
        _appGradient = gradient;
      });
    }
  }

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
                icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 28),
                onPressed: _logout,
                tooltip: 'Logout',
              );
            },
          )
        ],
      ),
      body: _appGradient == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: _appGradient),
              child: SafeArea(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white,));
                    }

                    final userData = snapshot.data ?? {'name': 'Guest', 'is_admin': false, 'is_guest': true};
                    final displayName = userData['name'];
                    final isAdmin = userData['is_admin'];

                    return _buildContent(displayName, isAdmin);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildContent(String displayName, bool isAdmin) {
    return Column(
      children: [
        _buildHeader(displayName, isAdmin),
        Expanded(
          child: _buildMenuGrid(isAdmin),
        ),
      ],
    );
  }

  Widget _buildHeader(String displayName, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome,',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
          ),
          Text(
            displayName,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
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

  Widget _buildMenuGrid(bool isAdmin) {
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
          onTap: () => Navigator.pushNamed(context, '/category'),
        ),
        _MenuItem(
          title: 'Ranking',
          icon: Icons.leaderboard_rounded,
          color: Colors.lightBlueAccent,
          onTap: () => Navigator.pushNamed(context, '/ranking'),
        ),
        _MenuItem(
          title: 'Profile',
          icon: Icons.person_rounded,
          color: Colors.greenAccent,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        _MenuItem(
          title: 'Settings',
          icon: Icons.settings_rounded,
          color: Colors.purpleAccent,
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        if (isAdmin)
          _MenuItem(
            title: 'Admin Panel',
            icon: Icons.admin_panel_settings_rounded,
            color: Colors.redAccent,
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

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8)],
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

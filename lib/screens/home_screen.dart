import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();

    final user = AuthService.currentUser();
    if (user == null) {
      _profileFuture = Future.value(null);
    } else {
      _profileFuture = AuthService.getProfileByAuthId(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final profile = snapshot.data;

            final name = profile?['name'] as String?;
            final isAdmin = profile?['is_admin'] == true;

            final displayName =
                (name == null || name.isEmpty) ? 'Guest' : name;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $displayName 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (isAdmin)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                _menu(context, 'Play Quiz', Icons.play_arrow, '/category'),
                _menu(context, 'Ranking', Icons.leaderboard, '/ranking'),
                _menu(context, 'Profile', Icons.person, '/profile'),
                _menu(context, 'Settings', Icons.settings, '/settings'),

                // 🔥 ADMIN MENU
                if (isAdmin)
                  _menu(
                    context,
                    'Admin Panel',
                    Icons.admin_panel_settings,
                    '/admin',
                    color: Colors.red.shade50,
                    iconColor: Colors.red,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    String title,
    IconData icon,
    String route, {
    Color? color,
    Color? iconColor,
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

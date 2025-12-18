import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
import 'package:quiz_game/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffects = true;
  bool _backgroundMusic = false;
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

  void _restartApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const QuizGameApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _appGradient == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: _appGradient),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildSectionHeader('Theme'),
                    _buildThemeSelector(),
                    const Divider(color: Colors.white24, height: 40),
                    _buildSectionHeader('Audio'),
                    _buildSwitchTile(
                      title: 'Sound Effects',
                      subtitle: 'Enable or disable in-game sounds',
                      value: _soundEffects,
                      onChanged: (val) => setState(() => _soundEffects = val),
                      icon: Icons.volume_up_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      title: 'Background Music',
                      subtitle: 'Enable or disable background music',
                      value: _backgroundMusic,
                      onChanged: (val) => setState(() => _backgroundMusic = val),
                      icon: Icons.music_note_rounded,
                    ),
                    const Divider(color: Colors.white24, height: 40),
                    _buildSectionHeader('About'),
                    _buildInfoTile(
                      title: 'About Quiz Game',
                      icon: Icons.info_rounded,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Quiz Game',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2024 Gemini',
                          children: [
                            const Text('A fun quiz game for everyone, powered by Gemini.'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_rounded,
                      onTap: () { /* TODO: Navigate to privacy policy page or URL */ },
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      title: 'Terms of Service',
                      icon: Icons.description_rounded,
                      onTap: () { /* TODO: Navigate to terms of service page or URL */ },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Header Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ThemeHelper.gradients.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await ThemeHelper.setTheme(index);
                      _restartApp(); // Restart to apply changes
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: ThemeHelper.gradients[index]),
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: Icon(icon, color: Colors.white),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
import 'package:quiz_game/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffects = true;
  bool _backgroundMusic = false;
  int _currentThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentThemeIndex();
    _loadAudioSettings();
  }

  void _loadAudioSettings() async {
    await AudioService.init();
    final prefs = await SharedPreferences.getInstance();
    final sfx = prefs.getBool('sound_effects') ?? true;
    final bgm = prefs.getBool('background_music') ?? false;
    if (mounted) {
      setState(() {
        _soundEffects = sfx;
        _backgroundMusic = bgm;
      });
    }
    if (bgm) {
      await AudioService.playBgm();
    } else {
      await AudioService.stopBgm();
    }
  }

  void _loadCurrentThemeIndex() async {
    final index = await ThemeHelper.getCurrentThemeIndex();
    if (mounted) {
      setState(() {
        _currentThemeIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context)!;
    final isLightTheme = themeProvider.textColor == Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
                _buildSectionHeader('Appearance', themeProvider.textColor),
              _buildThemeSelector(themeProvider.setTheme, isLightTheme),
              const Divider(color: Colors.white24, height: 40),
              _buildSectionHeader('Audio', themeProvider.textColor),
              _buildSwitchTile(
                title: 'Sound Effects',
                subtitle: 'Toggle in-game sound effects',
                value: _soundEffects,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('sound_effects', val);
                  if (val) {
                    await AudioService.playButtonSound();
                  }
                  if (mounted) setState(() => _soundEffects = val);
                },
                icon: Icons.volume_up_rounded,
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Background Music',
                subtitle: 'Toggle background music',
                value: _backgroundMusic,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('background_music', val);
                  if (val) {
                    await AudioService.playBgm();
                  } else {
                    await AudioService.stopBgm();
                  }
                  if (mounted) setState(() => _backgroundMusic = val);
                },
                icon: Icons.music_note_rounded,
                 isLightTheme: isLightTheme,
              ),
              const Divider(color: Colors.white24, height: 40),
              _buildSectionHeader('About', themeProvider.textColor),
              _buildInfoTile(
                title: 'About Quiz Game',
                icon: Icons.info_rounded,
                 isLightTheme: isLightTheme,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Quiz Game',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Gemini',
                    children: [
                      const Text('A fun quiz game for everyone, created by the stupidBird team.'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_rounded,
                 isLightTheme: isLightTheme,
                onTap: () { /* TODO: Navigate to privacy policy page or URL */ },
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                title: 'Terms of Service',
                icon: Icons.description_rounded,
                 isLightTheme: isLightTheme,
                onTap: () { /* TODO: Navigate to terms of service page or URL */ },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildThemeSelector(Function(int) setTheme, bool isLightTheme) {
    final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.2);
    final textColor = isLightTheme ? Colors.black87 : Colors.white;

    return Card(
      color: cardColor,
      elevation: isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Màu nền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ThemeHelper.themes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = index == _currentThemeIndex;
                  return GestureDetector(
                    onTap: () {
                      setTheme(index);
                      setState(() => _currentThemeIndex = index);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: ThemeHelper.themes[index].colors),
                            border: Border.all(color: isSelected ? Colors.white : (isLightTheme ? Colors.grey.shade400 : Colors.white.withOpacity(0.6)), width: isSelected ? 3 : 2),
                            boxShadow: isSelected ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0,2))] : null,
                          ),
                          child: isSelected 
                              ? Icon(Icons.check, color: ThemeHelper.themes[index].textColor == Colors.white ? Colors.white : Colors.black)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(isSelected ? 'Đã chọn' : '', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 12)),
                        ),
                      ],
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
    required bool isLightTheme,
  }) {
    final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.2);
    final titleColor = isLightTheme ? Colors.black87 : Colors.white;
    final subtitleColor = isLightTheme ? Colors.grey.shade600 : Colors.white.withOpacity(0.7);

    return Card(
      color: cardColor,
      elevation: isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
        subtitle: Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: titleColor),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLightTheme,
  }) {
    final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.2);
    final textColor = isLightTheme ? Colors.black87 : Colors.white;

    return Card(
      color: cardColor,
      elevation: isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        leading: Icon(icon, color: textColor),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }
}

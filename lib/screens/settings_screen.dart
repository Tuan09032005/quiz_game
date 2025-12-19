import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:quiz_game/helpers/theme_helper.dart';

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
              _buildSectionHeader('Giao diện', themeProvider.textColor),
              _buildThemeSelector(themeProvider.setTheme, isLightTheme),
              const Divider(color: Colors.white24, height: 40),
              _buildSectionHeader('Âm thanh', themeProvider.textColor),
              _buildSwitchTile(
                title: 'Hiệu ứng âm thanh',
                subtitle: 'Bật/tắt âm thanh trong game',
                value: _soundEffects,
                onChanged: (val) => setState(() => _soundEffects = val),
                icon: Icons.volume_up_rounded,
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Nhạc nền',
                subtitle: 'Bật/tắt nhạc nền',
                value: _backgroundMusic,
                onChanged: (val) => setState(() => _backgroundMusic = val),
                icon: Icons.music_note_rounded,
                 isLightTheme: isLightTheme,
              ),
              const Divider(color: Colors.white24, height: 40),
              _buildSectionHeader('Giới thiệu', themeProvider.textColor),
              _buildInfoTile(
                title: 'Về Quiz Game',
                icon: Icons.info_rounded,
                 isLightTheme: isLightTheme,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Quiz Game',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Gemini',
                    children: [
                      const Text('Một trò chơi đố vui dành cho mọi người, được hỗ trợ bởi Gemini.'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                title: 'Chính sách bảo mật',
                icon: Icons.privacy_tip_rounded,
                 isLightTheme: isLightTheme,
                onTap: () { /* TODO: Navigate to privacy policy page or URL */ },
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                title: 'Điều khoản dịch vụ',
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
              height: 40,
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
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: ThemeHelper.themes[index].colors),
                        border: Border.all(color: isLightTheme ? Colors.grey.shade400 : Colors.white.withOpacity(0.7), width: 2),
                      ),
                      child: isSelected 
                          ? Icon(Icons.check, color: ThemeHelper.themes[index].textColor == Colors.white ? Colors.white : Colors.black)
                          : null,
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

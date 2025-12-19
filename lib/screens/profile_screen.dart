import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = true;
  String _email = '';
  String _name = '';
  int _totalScore = 0;
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool('isGuest') ?? true;

    if (_isGuest) {
      _name = prefs.getString('userName') ?? 'Guest';
      _email = 'Sign in to save your progress';
      _totalScore = 0;
    } else {
      final user = AuthService.currentUser();
      if (user != null) {
        _email = user.email ?? 'N/A';
        final profile = await AuthService.getProfileByAuthId(user.id);
        if (mounted) {
          _name = profile?['name'] ?? '';
          _totalScore = profile?['total_score'] ?? 0;
        }
      } else {
        _isGuest = true;
        _name = 'Guest';
        _email = 'Sign in to save your progress';
        _totalScore = 0;
      }
    }
    
    _nameController.text = _name;

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _updateProfile() async {
    if (_isGuest || !mounted) return;

    setState(() { _isLoading = true; });

    final user = AuthService.currentUser();
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      await AuthService.updateUserName(user.id, _nameController.text.trim());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        await _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context)!;
    final isLightTheme = themeProvider.textColor == Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: themeProvider.textColor)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: SafeArea(
          child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: themeProvider.textColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _isGuest ? _buildGuestContent(isLightTheme, themeProvider.textColor) : _buildUserContent(isLightTheme, themeProvider.textColor),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Icon(_isGuest ? Icons.help_outline_rounded : Icons.person_rounded, size: 50, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Text(_name, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(_email, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuestContent(bool isLightTheme, Color textColor) {
    return Column(
      children: [
        _buildHeader(textColor),
        Card(
          color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.2),
          elevation: isLightTheme ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.person_off_outlined, color: isLightTheme ? Colors.grey[600] : Colors.white70, size: 60),
                const SizedBox(height: 16),
                Text(
                  'You are a Guest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLightTheme ? Colors.black87 : Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to save your profile and track your score.',
                  style: TextStyle(color: isLightTheme ? Colors.grey[600] : Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLightTheme ? Colors.blueAccent : Colors.white,
                    foregroundColor: isLightTheme ? Colors.white : Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                  child: const Text('Login or Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserContent(bool isLightTheme, Color textColor) {
    return Column(
      children: [
        _buildHeader(textColor),
        _buildInfoCard(isLightTheme),
        const SizedBox(height: 20),
        _buildEditCard(isLightTheme),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLightTheme ? Colors.blueAccent : Colors.white,
            foregroundColor: isLightTheme ? Colors.white : Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          onPressed: _updateProfile,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('Logout'),
          style: TextButton.styleFrom(foregroundColor: textColor.withOpacity(0.8)),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isLightTheme) {
    return Card(
      color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.2),
      elevation: isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Total Score', style: TextStyle(fontSize: 14, color: isLightTheme ? Colors.grey[600] : Colors.white.withOpacity(0.8))),
                const SizedBox(height: 8),
                Text(
                  _totalScore.toString(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isLightTheme ? Colors.blueAccent : Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCard(bool isLightTheme) {
    final textColor = isLightTheme ? Colors.black87 : Colors.white;

    return Card(
      color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.2),
      elevation: isLightTheme ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Your Name',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor), borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.person_outline, color: textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

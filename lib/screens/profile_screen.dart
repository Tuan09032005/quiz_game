import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _userRow;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
    });

    final authUser = AuthService.currentUser();
    if (authUser == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final row = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      _userRow = Map<String, dynamic>.from(row);
      _nameController.text = _userRow?['name']?.toString() ?? '';
    } catch (e) {
      // ignore errors for now; UI will show empty state
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _save() async {
    final authUser = AuthService.currentUser();
    if (authUser == null) return;

    setState(() {
      _loading = true;
    });

    try {
      await SupabaseService.client.from('users').update({
        'name': _nameController.text.trim(),
      }).eq('id', authUser.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated')),
      );
      await _loadUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService.currentUser();

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(authUser?.email ?? (_userRow?['email']?.toString() ?? 'N/A')),
                  SizedBox(height: 16),
                  Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your name',
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Total score', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(_userRow?['total_score']?.toString() ?? '0'),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _save,
                          child: Text('Save'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: Icon(Icons.logout, color: Colors.red),
                          label: Text('Logout', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });

    try {
      await AuthService.signOut();
    } catch (e) {
      // ignore sign out errors
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

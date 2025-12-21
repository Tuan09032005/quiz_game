import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AuthService.fetchAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAdmin(String authId, bool current) async {
    try {
      await AuthService.setUserAdmin(authId, !current);
      await _loadUsers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated role')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update role: $e')));
    }
  }

  Future<void> _deleteUser(String authId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Delete user record? This removes the user row only.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.deleteUserRecord(authId);
      await _loadUsers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: _users.isEmpty
                  ? ListView(children: const [SizedBox(height: 200), Center(child: Text('No users found'))])
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final u = _users[index];
                        final name = u['name'] ?? 'Unnamed';
                        final email = u['email'] ?? '';
                        final score = u['total_score'] ?? 0;
                        final isAdmin = u['is_admin'] == true;
                        final authId = u['auth_id'] ?? '';

                        final currentUser = AuthService.currentUser();
                        final canDelete = currentUser == null ? false : currentUser.id != authId;

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('$email • Score: $score', style: const TextStyle(fontSize: 12)),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'toggle') {
                                  await _toggleAdmin(authId, isAdmin);
                                } else if (value == 'delete') {
                                  await _deleteUser(authId);
                                }
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: ListTile(
                                    leading: Icon(isAdmin ? Icons.remove_moderator : Icons.admin_panel_settings, color: isAdmin ? Colors.orange : null),
                                    title: Text(isAdmin ? 'Revoke admin' : 'Make admin'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  enabled: canDelete,
                                  child: ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                                    title: Text(canDelete ? 'Delete user' : 'Cannot delete self'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

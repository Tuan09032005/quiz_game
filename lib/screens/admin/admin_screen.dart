import 'package:flutter/material.dart';
import 'admin_category_screen.dart';
import 'admin_question_screen.dart';
import 'user_management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cross = constraints.maxWidth > 700 ? 2 : 1;
            return GridView.count(
              crossAxisCount: cross,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: cross == 2 ? 4 : 5,
              children: [
                _card(context, 'Manage Categories', Icons.category_outlined, const AdminCategoryScreen()),
                _card(context, 'Manage Questions', Icons.quiz_outlined, const AdminQuestionScreen()),
                _card(context, 'Manage Users', Icons.manage_accounts_outlined, const UserManagementScreen()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Tap to open', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

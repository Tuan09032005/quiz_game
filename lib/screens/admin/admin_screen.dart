import 'package:flutter/material.dart';
import 'admin_category_screen.dart';
import 'admin_question_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _item(
              context,
              'Manage Categories',
              Icons.category,
              const AdminCategoryScreen(),
            ),
            _item(
              context,
              'Manage Questions',
              Icons.help_outline,
              const AdminQuestionScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}

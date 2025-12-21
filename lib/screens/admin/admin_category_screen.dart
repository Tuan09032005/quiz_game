import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.getCategories();
  }

  void _addCategory() async {
    final ctrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category name cannot be empty')),
                );
                return;
              }

              final existing = await SupabaseService.getCategories();
              final exists = existing.any((e) =>
                  e['name'] != null &&
                  e['name'].toString().toLowerCase() == name.toLowerCase());
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category already exists')),
                );
                return;
              }

              await SupabaseService.addCategory(name: name);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category added')),
              );
              setState(() => _future = SupabaseService.getCategories());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          )
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return ListTile(
                title: Text(c['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool?>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Category'),
                        content: const Text('Delete this category and all its questions?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final catId = c['id'].toString();
                      await SupabaseService.deleteCategoryAndQuestions(categoryId: catId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category and its questions deleted')),
                      );
                      setState(() => _future = SupabaseService.getCategories());
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

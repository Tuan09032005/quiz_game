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
              await SupabaseService.client.from('categories').insert({
                'name': ctrl.text,
              });
              Navigator.pop(context);
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
              );
            },
          );
        },
      ),
    );
  }
}

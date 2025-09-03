import 'package:flutter/material.dart';
import '../models/list.dart';

class ListCard extends StatelessWidget {
  final ListModel list;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text(
          list.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete list"),
                    content: const Text(
                        "Are you sure you want to delete this list?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // nur schließen
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Dialog schließen
                          onDelete(); // Callback ausführen
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

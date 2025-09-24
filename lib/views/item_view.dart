import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/list_model.dart';
import '../services/database_service.dart';

class ItemPage extends StatefulWidget {
  final ItemModel item;
  final DatabaseService db;
  final ListModel list;

  const ItemPage({super.key, required this.item, required this.db, required this.list});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _amountCtrl;
  late double _currentPriority;
  List<String> get _itemAttributes => widget.list.allowedAttributes;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    if (_itemAttributes.contains("description")) {
      _descriptionCtrl = TextEditingController(text: widget.item.description);
    }
    if (widget.item.amount != null) {
      _amountCtrl = TextEditingController(text: widget.item.amount);
    } else {
      _amountCtrl = TextEditingController();
    }
    if (widget.item.priority != null) {
      _currentPriority = widget.item.priority!.toDouble();
    } else{
      _currentPriority = 3.0;
    }
  }


  Future<void> _saveChanges() async {
    final newTitle = _titleCtrl.text.trim();
    String? newDescription;
    if (_itemAttributes.contains("description")) {
      final text = _descriptionCtrl.text.trim();
      newDescription = text.isEmpty ? null : text;
    } else {
      newDescription = null;
    }

    String? newAmount;
    if (_itemAttributes.contains("amount")) {
      final text = _amountCtrl.text.trim();
      newAmount = text.isEmpty ? null : text;
    } else {
      newAmount = null;
    }

    int? newPriority;
    if (_itemAttributes.contains("priority")) {
      newPriority = _currentPriority.round();
    } else {
      newPriority = null;
    }

    try {
      final updatedItem = widget.item.copyWith(
        title: newTitle,
        description: newDescription,
        amount: newAmount,
        priority: newPriority,
      );

      await widget.db.items.updateItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child:Text('Item updated successfully!'),)),
        );
        Navigator.of(context).pop(updatedItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Failed to update item: $e'),)),
        );
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            // Description
            if (_itemAttributes.contains("description")) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
            // Amount
            if (_itemAttributes.contains("amount")) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
            ],
            // Priority
            if (_itemAttributes.contains("priority")) ...[
              const SizedBox(height: 12),
              const Text("Priority"),
              Slider(
                value: _currentPriority,
                divisions: 4,
                max: 5,
                min: 1,
                label: _currentPriority.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentPriority = value;
                  });
                },
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
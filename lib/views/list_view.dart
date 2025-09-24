import 'package:flutter/material.dart';

import '../models/list_model.dart';
import '../models/unfinished_item_model.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../widgets/item_card.dart';
import 'item_view.dart';

class ListPage extends StatefulWidget {
  final ListModel list;
  final DatabaseService db;

  const ListPage({super.key, required this.list, required this.db});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ItemModel> _items = [];
  List<String> get _itemAttributes => widget.list.allowedAttributes;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void toggleCompleted(ItemModel item) async {
    setState(() {
      item.completed = !item.completed;
    });
    await widget.db.items.updateItem(item);
  }

  Future<void> loadItems() async {
    final fetchedItems = await widget.db.items.getItemsForList(widget.list.id);
    setState(() {
      _items = fetchedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.list.title)),
      body: _items.isEmpty
          ? const Center(child: Text("No items yet"))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ItemCard(
            item: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemPage(item: _items[index], db: widget.db),
                ),
              );
            },
            onDelete: () {
              setState(() {
                widget.db.items.deleteItem(item.id);
                loadItems();
              });
            },
            onToggle: (val) => toggleCompleted(item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        //TODO: show all possible values if template is custom, for real templates show the fields to fill (mark must-fill fields)
        onPressed: _showItemCreationDialog,
        tooltip: "Create Item",
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showItemCreationDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _amountController.clear();
    double priority = 3.0;


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Create Item"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_itemAttributes.contains("title"))
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Title",
                      ),
                    ),

                  if (_itemAttributes.contains("description")) ...[
                    const SizedBox(height: 5),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                    ),
                  ],

                  if (_itemAttributes.contains("amount")) ...[
                    const SizedBox(height: 5),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Amount",
                      ),
                    ),
                  ],

                  if (_itemAttributes.contains("priority")) ...[
                    const SizedBox(height: 15),
                    const Text("Priority"),
                    Slider(
                      value: priority,
                      divisions: 4,
                      max: 5,
                      min: 1,
                      label: priority.round().toString(),
                      onChanged: (double value) {
                        setStateDialog(() {
                          priority = value;

                        });
                      },
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                TextButton(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty) {
                      int? priorityInt;
                      if (_itemAttributes.contains("priority")) {
                        priorityInt = priority.round();
                      }

                      await widget.db.items.addItem(
                        UnfinishedItemModel(
                          listId: widget.list.listId,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          amount: _amountController.text,
                          priority: priorityInt,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        )
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      await loadItems();
                    }
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

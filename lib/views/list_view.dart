import 'package:Dictanote/models/list_model.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../widgets/item_card.dart';

class ListPage extends StatefulWidget {
  final ListModel list;

  const ListPage({super.key, required this.list});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final DatabaseService db;
  List<ItemModel> _items = [];
  List<String> get _itemAttributes => widget.list.allowedAttributes;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DatabaseService();
    loadItems();
  }

  void toggleCompleted(ItemModel item) async { ///TODO db
    setState(() {
      item.completed = !item.completed;
    });    //await db.updateItemCompletion(item, !item.completed);
    //loadItems();
  }

  // TODO: do the same for home_view with lists
  Future<void> loadItems() async {
    final fetchedItems = await db.getItemsForList(widget.list.id);
    setState(() {
      _items = fetchedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.list.title)),
      body: _items.isEmpty
          ? const Center(child: Text("No items yet"))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ItemCard(
            item: item,
            onTap: () {
              // TODO: detail view for item in item_view.dart
            },
            onDelete: () {
              setState(() {
                _items.removeAt(index);
              });
              // TODO: call db for deletion --> loadItems()
            },
            // TODO: call db --> loadItems()
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

                      setState(() { //TODO: create Entry in db (also Link list and item)--> Create itemModel --> Link this list and itemModel
                          _items.add(
                              ItemModel(
                            id: DateTime.now().millisecondsSinceEpoch,
                            listId: widget.list.listId,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            amount: int.tryParse(_amountController.text),
                            priority: priorityInt,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now()
                          )
                        );
                      });
                      Navigator.pop(context);
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

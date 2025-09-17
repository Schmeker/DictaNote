import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../widgets/item_card.dart';

class ListPage extends StatefulWidget {
  final int listId;
  final String listTitle;

  const ListPage({super.key, required this.listId, required this.listTitle});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late DatabaseService db;
  List<ItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    db = DatabaseService();
    loadItems();
  }

  Future<void> loadItems() async {
    final fetchedItems = await db.getItemsForList(widget.listId);
    setState(() {
      _items = fetchedItems;
    });
  }

  void toggleCompleted(ItemModel item) async {
    await db.updateItemCompletion(item, !item.completed);
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.listTitle)),
      body: _items.isEmpty
          ? const Center(child: Text("No items yet"))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ItemCard(
            item: item,
            onTap: () {
              // Optional: detail view for item
            },
            onDelete: () {
              setState(() {
                _items.removeAt(index);
              });
              // TODO: call db.deleteItem(item.id);
            },
            onToggle: (val) => toggleCompleted(item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';

class ItemPage extends StatelessWidget {
  final ItemModel item;
  final DatabaseService db;

  const ItemPage({super.key, required this.item, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text(item.title)),
      body: const Center(
        child: Text("Item settings here"),

      ),
    );
  }
}

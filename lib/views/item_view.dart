import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemPage extends StatelessWidget {
  final ItemModel list;

  const ItemPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(list.title)),
      body: const Center(
        child: Text("Settings in here"),
      ),
    );
  }
}

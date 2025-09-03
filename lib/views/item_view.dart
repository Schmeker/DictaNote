import 'package:flutter/material.dart';
import '../models/item.dart';

class ListPage extends StatelessWidget {
  final ItemModel list;

  const ListPage({super.key, required this.list});

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

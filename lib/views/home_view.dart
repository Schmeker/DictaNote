import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart' as grp;

import '../models/list_model.dart';
import '../models/unfinished_list_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../widgets/list_card.dart';

import 'list_view.dart';


enum Template { toDo, shopping, custom }

class HomePage extends StatefulWidget {
  final UserModel user;
  final DatabaseService db;

  HomePage({super.key, required this.user, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ListModel> _lists = [];

  Template _selectedTemplate = Template.values.first;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOwnLists();
  }

  Future<void> loadOwnLists() async {
    final fetchedItems = await widget.db.lists.getListsForUser(widget.user.id);
    setState(() {
      _lists = fetchedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello ${widget.user.username}")),
      body: _lists.isEmpty
          ? const Center(child: Text("No lists created"))
          : ListView.builder(
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final list = _lists[index];
          return ListCard(
            list: list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListPage(list: _lists[index], db: widget.db),
                ),
              );
            },
            onDelete: () async {
              await widget.db.lists.deleteList(list.id);
              await loadOwnLists();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTemplateSelectionDialog,
        tooltip: 'Choose template',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTemplateSelectionDialog() {
    _customController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Choose template"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  grp.RadioGroup<Template>.builder(
                    groupValue: _selectedTemplate,
                    onChanged: (value) => setStateDialog(() {
                      _selectedTemplate = value!;
                    }),
                    items: Template.values,
                    itemBuilder: (template) => grp.RadioButtonBuilder(
                      template.name,
                    ),
                  ),
                  TextField(
                    controller: _customController,
                    decoration: const InputDecoration(labelText: "Create title"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                TextButton(
                  onPressed: () async {
                    String title = _customController.text.isEmpty
                        ? _selectedTemplate.name
                        : _customController.text;

                    await widget.db.lists.addList(
                      UnfinishedListModel(
                        title: title,
                        ownerId: widget.user.id,
                        type: _selectedTemplate,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    await loadOwnLists();
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

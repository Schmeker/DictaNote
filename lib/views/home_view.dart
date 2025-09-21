import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart' as grp;

import '../providers/user_provider.dart';
import '../models/list_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../widgets/list_card.dart';

import 'list_view.dart';


enum Template { toDo, shopping, custom }

class HomePage extends StatefulWidget {
// final UserModel user

  //required this.user
  HomePage({super.key,});

  // TODO fetch user from database
  final UserModel user = UserModel(id: 1, username: "joni", email: "joniwinter6@gmail.com", passwordHash: "123jgbas3213", firstname: "Jonathan", lastname: "Winter");

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseService db;
  final List<ListModel> _lists = [];

  Template _selectedTemplate = Template.values.first;
  final TextEditingController _customController = TextEditingController();


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
                  builder: (_) => ListPage(list: _lists[index]),
                ),
              );
            },
            onDelete: () {
              setState(() {
                //TODO: remove from database, then fetch list instead of deleting bsp: _lists.load();
                _lists.removeAt(index);
              });
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
                  onPressed: () {
                    //TODO: index lists title if already same name exists: toDo, toDo 2, toDo 3, ....
                    String title = _customController.text.isEmpty
                        ? _selectedTemplate.name
                        : _customController.text;

                    setState(() {
                      //TODO: push to db, db should send id back to add it to the list, maybe first upload to db, so we can just give the id to the list, also id is currently a workaround
                      _lists.add(ListModel( id: DateTime.now().millisecondsSinceEpoch, title: title, ownerId: 1, type: _selectedTemplate, createdAt: DateTime.now(), updatedAt: DateTime.now()));
                    });

                      Navigator.pop(context);
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

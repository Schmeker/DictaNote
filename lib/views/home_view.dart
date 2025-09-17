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
  //required this.userId
  HomePage({super.key,});

  // TODO fetch user from database. do it later
  final UserModel user = UserModel(username: "joni", email: "joniwinter6@gmail.com", passwordHash: "123jgbas3213", firstname: "Jonathan", lastname: "Winter");

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseService db;
  final List<ListModel> _lists = [];

  Template? _selectedTemplate;
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
                  //TODO: This is a workaround Maybe fetch from db??
                  builder: (_) => ListPage(listId: _lists[index].ownerId, listTitle: _lists[index].title,),
                ),
              );
            },
            onDelete: () {
              setState(() {
                //TODO: remove from database, then fetch list instead of deleting a
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
                    groupValue: _selectedTemplate ?? Template.values.first,
                    onChanged: (value) => setStateDialog(() {
                      _selectedTemplate = value;
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
                    if (_selectedTemplate != null) {
                      if( _customController.text.isNotEmpty){
                        String title = _customController.text;

                        setState(() {
                          //TODO: this is a workaround fix owner and timestamps
                          DateTime emptyDateTime = DateTime.fromMillisecondsSinceEpoch(0);
                          _lists.add(ListModel(title: title, ownerId: 1, type: _selectedTemplate.toString(), createdAt: emptyDateTime , updatedAt: emptyDateTime));
                          //TODO: push to db, db should send id back to add it to the list, maybe first upload to db, so we can just give the id to the list
                        });

                        Navigator.pop(context);

                        setState(() {
                          _selectedTemplate = null;
                          _customController.clear();
                        });
                      }
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

import 'package:flutter/material.dart';
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

  //final String title = "Hello " + UserModel.getUsername(user);

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
                  //TODO: This is a workaround
                  builder: (_) => ListPage(listId: 1, listTitle: "hallo",),
                ),
              );
            },
            onDelete: () {
              setState(() {
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
                  ...Template.values.map((template) {
                    return RadioListTile<Template>(
                      title: Text(template.name),
                      value: template,
                      groupValue: _selectedTemplate,
                      onChanged: (Template? value) {
                        setStateDialog(() {
                          _selectedTemplate = value;
                        });
                      },
                    );
                  }),
                  TextField(
                    controller: _customController,
                    decoration:
                    const InputDecoration(labelText: "Create title"),
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
                          //TODO: this is wa workaround
                          DateTime emptyDateTime = DateTime.fromMillisecondsSinceEpoch(0);
                          _lists.add(ListModel(title: title, ownerId: 1, type: 'todo', createdAt: emptyDateTime , updatedAt: emptyDateTime));
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

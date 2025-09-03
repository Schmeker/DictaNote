import 'package:flutter/material.dart';
import 'list_view.dart';
import '../models/list.dart';
import '../widgets/list_card.dart';


enum Template { toDo, shopping, custom }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Template? _selectedTemplate;
  final TextEditingController _customController = TextEditingController();

  final List<ListModel> _lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                  builder: (_) => ListPage(list: list),
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
                          _lists.add(ListModel(title: title));
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

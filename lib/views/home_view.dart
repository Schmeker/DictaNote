import 'package:group_radio_button/group_radio_button.dart' as grp;
import 'package:flutter/material.dart';

import '../models/list_model.dart';
import '../models/user_model.dart';
import '../models/unfinished_list_model.dart';
import '../services/database_service.dart';
import '../widgets/list_card.dart';
import '../views/list_view.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';

enum ProfileAction { editProfile, signOut, deleteAccount }

enum Template { shopping, toDo, custom }

class HomePage extends StatefulWidget {
  final UserModel user;
  final DatabaseService db;

   HomePage({super.key, required this.user, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel _currentUser;
  List<ListModel> _lists = [];

  Template _selectedTemplate = Template.values.first;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadDataForCurrentUser();
  }

  Future<void> _loadDataForCurrentUser() async {
    final fetchedLists = await widget.db.lists.getListsForUser(_currentUser.id);
    if (mounted) {
      setState(() {
        _lists = fetchedLists;
      });
    }
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);

    if (mounted) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginView(db: widget.db)),
            (Route<dynamic> route) => false,
      );
    }
  }


  Future<void> _deleteAccount() async {
    final currentContext = context;
    final messenger = ScaffoldMessenger.of(currentContext);

    final confirmDelete = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await widget.db.users.deleteUser(_currentUser.id);
        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(content: Center(child:Text('Account deleted successfully.'),)),
        );

        if (mounted) {
          Navigator.of(currentContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginView(db: widget.db)),
                (Route<dynamic> route) => false,
          );
        }

      } catch (e) {
        if (!mounted) return; // Check mounted *after* await
        messenger.showSnackBar(
          SnackBar(content: Center(child:Text('Failed to delete account: $e'),)),
        );
      }
    }
  }

  Future<void> _editProfile() async {
    final currentContext = context;
    final messenger = ScaffoldMessenger.of(currentContext);

    final updatedUser = await Navigator.push<UserModel>(
      currentContext,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileView(user: _currentUser, db: widget.db),
      ),
    );

    if (!mounted) return;

    if (updatedUser != null) {
      setState(() {
        _currentUser = updatedUser;
      });
      messenger.showSnackBar(
        const SnackBar(content: Center(child:Text('Profile updated!'),)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, title: Text('Welcome, ${_currentUser.username}'),
        actions: [
          PopupMenuButton<ProfileAction>(
            icon: const Icon(Icons.account_circle),
            iconSize: 30,
            tooltip: "Profile",
            offset: Offset(-10, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (ProfileAction result) {
              switch (result) {
                case ProfileAction.editProfile:
                  _editProfile();
                  break;
                case ProfileAction.signOut:
                  _signOut();
                  break;
                case ProfileAction.deleteAccount:
                  _deleteAccount();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileAction>>[
              PopupMenuItem<ProfileAction>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentUser.username, style: Theme.of(context).textTheme.titleMedium),
                    Text(_currentUser.email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<ProfileAction>(
                value: ProfileAction.editProfile,
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit Profile'),
                ),
              ),
              const PopupMenuItem<ProfileAction>(
                value: ProfileAction.signOut,
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out'),
                ),
              ),
              const PopupMenuItem<ProfileAction>(
                value: ProfileAction.deleteAccount,
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete Account', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
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
              await _loadDataForCurrentUser();
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
                          ownerId: _currentUser.id,
                          type: _selectedTemplate,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      await _loadDataForCurrentUser();
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

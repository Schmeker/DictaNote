import 'package:flutter/material.dart';

void main() {
  runApp(const DictaNoteApp());
}

class DictaNoteApp extends StatelessWidget {
  const DictaNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DictaNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const NotesPage(),
    );
  }
}

/// ----------------------
/// Notizen-Übersicht
/// ----------------------
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Map<String, String>> _notes = [
    {'title': 'Willkommen', 'content': 'Dies ist deine erste Notiz 🎉'},
  ];

  void _addNote(String title, String content) {
    setState(() {
      _notes.add({'title': title, 'content': content});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DictaNote')),
      body: ListView.separated(
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note['title'] ?? ''),
            subtitle: Text(
              note['content'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorPage(
                    onSave: _addNote,
                    initialTitle: note['title'],
                    initialContent: note['content'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteEditorPage(onSave: _addNote),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ----------------------
/// Notiz-Editor
/// ----------------------
class NoteEditorPage extends StatefulWidget {
  final Function(String, String) onSave;
  final String? initialTitle;
  final String? initialContent;

  const NoteEditorPage({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    widget.onSave(title.isEmpty ? 'Ohne Titel' : title, content);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notiz bearbeiten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Titel'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: 'Notiz schreiben...'),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

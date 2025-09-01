import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/note_model.dart';
import '../utils/format.dart';
import '../widgets/template_card.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<NoteModel> _notes = [
    NoteModel(
      title: 'Willkommen 👋',
      quillDeltaJson: jsonEncode([
        {'insert': 'Willkommen bei DictaNote'},
        {'insert': '\n', 'attributes': {'header': 1}},
        {'insert': 'Tippe auf '},
        {'insert': 'Neu', 'attributes': {'italic': true}},
        {'insert': ', wähle eine Vorlage und formatiere mit der Toolbar.'},
        {'insert': '\n'}
      ]),
      preview: 'Willkommen bei DictaNote',
      template: NoteTemplate.blank,
      emoji: '✨',
      colorIndex: 0,
    ),
  ];

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ========= In DIE KLASSE INTEGRIERT: Delta-Vorlagen =========
  List<Map<String, dynamic>> _deltaForTemplate(NoteTemplate t) {
    switch (t) {
      case NoteTemplate.blank:
        return [
          {'insert': 'Neue Notiz'},
          {'insert': '\n', 'attributes': {'header': 1}},
          {'insert': '\n'},
        ];
      case NoteTemplate.todo:
        return [
          {'insert': 'To-Do'},
          {'insert': '\n', 'attributes': {'header': 1}},
          {'insert': 'Erstes To-Do'},
          {'insert': '\n', 'attributes': {'list': 'unchecked'}},
          {'insert': 'Zweites To-Do'},
          {'insert': '\n', 'attributes': {'list': 'unchecked'}},
          {'insert': '\n'},
        ];
      case NoteTemplate.meeting:
        return [
          {'insert': 'Meeting Notes'},
          {'insert': '\n', 'attributes': {'header': 1}},
          {'insert': 'Datum: ${DateTime.now().toString().split(' ').first}\nTeilnehmer: …\n\n'},
          {'insert': 'Agenda'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': 'Thema 1'},
          {'insert': '\n', 'attributes': {'list': 'bullet'}},
          {'insert': 'Thema 2'},
          {'insert': '\n', 'attributes': {'list': 'bullet'}},
          {'insert': '\n'},
          {'insert': 'Notizen'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': '\n'},
          {'insert': 'Entscheidungen'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': '\n'},
          {'insert': 'Action Items'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': 'Aufgabe – Verantwortlich – Fällig …'},
          {'insert': '\n', 'attributes': {'list': 'unchecked'}},
          {'insert': '\n'},
        ];
      case NoteTemplate.journal:
        return [
          {'insert': 'Journal'},
          {'insert': '\n', 'attributes': {'header': 1}},
          {'insert': 'Datum: ${DateTime.now().toString().split(' ').first}\n\n'},
          {'insert': 'Heute passiert'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': '\n'},
          {'insert': 'Gedanken'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': '\n'},
          {'insert': 'Dankbarkeit'},
          {'insert': '\n', 'attributes': {'header': 2}},
          {'insert': '\n'},
        ];
    }
  }

  Future<void> _showTemplateSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vorlage wählen', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12, children: [
                  TemplateCard(
                    icon: Icons.description_outlined,
                    label: 'Leere Notiz',
                    color: cs.primaryContainer,
                    onTap: () => _createFromTemplate(NoteTemplate.blank, emoji: '📝', colorIndex: 0),
                  ),
                  TemplateCard(
                    icon: Icons.checklist_rounded,
                    label: 'To-Do Liste',
                    color: cs.tertiaryContainer,
                    onTap: () => _createFromTemplate(NoteTemplate.todo, emoji: '✅', colorIndex: 1),
                  ),
                  TemplateCard(
                    icon: Icons.meeting_room_outlined,
                    label: 'Meeting Notes',
                    color: cs.secondaryContainer,
                    onTap: () => _createFromTemplate(NoteTemplate.meeting, emoji: '📋', colorIndex: 2),
                  ),
                  TemplateCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Journal',
                    color: cs.surfaceContainerHighest,
                    onTap: () => _createFromTemplate(NoteTemplate.journal, emoji: '📔', colorIndex: 3),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createFromTemplate(
    NoteTemplate t, {
    required String emoji,
    required int colorIndex,
  }) async {
    Navigator.pop(context);
    final ops = _deltaForTemplate(t);
    final title = switch (t) {
      NoteTemplate.blank => 'Neue Notiz',
      NoteTemplate.todo => 'To-Do Liste',
      NoteTemplate.meeting => 'Meeting Notes',
      NoteTemplate.journal => 'Journal',
    };

    final note = NoteModel(
      title: title,
      quillDeltaJson: jsonEncode(ops),
      preview: (ops.isNotEmpty && ops.first['insert'] is String)
          ? (ops.first['insert'] as String)
          : title,
      template: t,
      emoji: emoji,
      colorIndex: colorIndex,
    );

    final res = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
    if (res != null) {
      setState(() => _notes.insert(0, res));
      _snack('Notiz gespeichert');
    }
  }

  Future<void> _openEditor(NoteModel n) async {
    final edited = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: n)),
    );
    if (edited != null) {
      setState(() {
        final idx = _notes.indexOf(n);
        if (idx >= 0) _notes[idx] = edited;
      });
      _snack('Änderungen gespeichert');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _notes.where((n) => n.pinned).toList();
    final others = _notes.where((n) => !n.pinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DictaNote'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (pinned.isNotEmpty) ...[
            _SectionHeader('Gepinnt'),
            const SizedBox(height: 8),
            ...pinned.map((n) => NoteCard(
                  note: n,
                  onTap: () => _openEditor(n),
                  onDelete: () => setState(() => _notes.remove(n)),
                  onPinToggle: () => setState(() => n.pinned = !n.pinned),
                )),
            const SizedBox(height: 16),
          ],
          _SectionHeader('Notizen'),
          const SizedBox(height: 8),
          if (others.isEmpty)
            const _EmptyState()
          else
            ...others.map((n) => NoteCard(
                  note: n,
                  onTap: () => _openEditor(n),
                  onDelete: () => setState(() => _notes.remove(n)),
                  onPinToggle: () => setState(() => n.pinned = !n.pinned),
                )),
          const SizedBox(height: 64),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTemplateSheet,
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 6, height: 18, decoration: BoxDecoration(
          color: cs.primary, borderRadius: BorderRadius.circular(3),
        )),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.note_alt_outlined, size: 56, color: cs.outline),
          const SizedBox(height: 10),
          Text('Noch keine Notizen', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Tippe auf „Neu“, um mit einer Vorlage zu starten.',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

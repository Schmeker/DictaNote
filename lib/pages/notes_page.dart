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
        {'insert': ', wähle eine Vorlage und nutze die Toolbar.'},
        {'insert': '\n'}
      ]),
      preview: 'Willkommen bei DictaNote',
      template: NoteTemplate.blank,
      emoji: '✨',
      colorIndex: 0,
      tags: ['intro', 'tipps'],
    ),
  ];

  // UI-State
  bool _fabOpen = false;
  bool _searchOpen = false;
  String _query = '';
  final Set<String> _activeTags = {};

  static const String kLogoPath = 'assets/icons/app_logo.png';

  @override
  void didChangeDependencies() {
    // Logo vorladen
    precacheImage(const AssetImage(kLogoPath), context);
    super.didChangeDependencies();
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---- Delta-Vorlagen (echtes Rich-Text) ----
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

  Future<void> _openTemplateSheet() async {
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
    NoteTemplate t, {required String emoji, required int colorIndex}) async {
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
      tags: t == NoteTemplate.todo ? ['todo'] : t == NoteTemplate.meeting ? ['meeting'] : [],
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

  // ---- Suche & Filter ----
  Iterable<NoteModel> get _filteredNotes sync* {
    final q = _query.trim().toLowerCase();
    for (final n in _notes) {
      final tagsOk = _activeTags.isEmpty || n.tags.any(_activeTags.contains);
      final textOk = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.preview.toLowerCase().contains(q);
      if (tagsOk && textOk) yield n;
    }
  }

  List<String> get _allTags {
    final s = <String>{};
    for (final n in _notes) { s.addAll(n.tags); }
    return s.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pinned = _filteredNotes.where((n) => n.pinned).toList();
    final others = _filteredNotes.where((n) => !n.pinned).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset('assets/icons/app_logo.png'),
        ),
        title: _searchOpen
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Suche…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('DictaNote'),
        actions: [
          IconButton(
            tooltip: _searchOpen ? 'Suche schließen' : 'Suche',
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searchOpen = !_searchOpen;
              if (!_searchOpen) _query = '';
            }),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
        children: [
          // Filterchips
          if (_allTags.isNotEmpty) ...[
            Wrap(
              spacing: 8, runSpacing: -6,
              children: _allTags.map((t) {
                final selected = _activeTags.contains(t);
                return FilterChip(
                  selected: selected,
                  label: Text(t),
                  onSelected: (_) => setState(() {
                    if (selected) { _activeTags.remove(t); } else { _activeTags.add(t); }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          if (pinned.isNotEmpty) ...[
            _SectionHeader('Gepinnt'),
            const SizedBox(height: 8),
            ...pinned.map((n) => _buildDismissible(n)),
            const SizedBox(height: 16),
          ],
          _SectionHeader('Notizen'),
          const SizedBox(height: 8),
          if (others.isEmpty)
            _EmptyState(onCreate: _openTemplateSheet)
          else
            ...others.map((n) => _buildDismissible(n)),
        ],
      ),

      // Speed-Dial-FAB (ohne Zusatzpaket)
      floatingActionButton: _FabMenu(
        open: _fabOpen,
        onToggle: () => setState(() => _fabOpen = !_fabOpen),
        items: [
          FabItem(icon: Icons.description_outlined, label: 'Leere Notiz',
              onTap: () => _openTemplateSheet()),
          FabItem(icon: Icons.checklist_rounded, label: 'To-Do',
              onTap: () => _createFromTemplate(NoteTemplate.todo, emoji: '✅', colorIndex: 1)),
          FabItem(icon: Icons.meeting_room_outlined, label: 'Meeting',
              onTap: () => _createFromTemplate(NoteTemplate.meeting, emoji: '📋', colorIndex: 2)),
          FabItem(icon: Icons.menu_book_outlined, label: 'Journal',
              onTap: () => _createFromTemplate(NoteTemplate.journal, emoji: '📔', colorIndex: 3)),
        ],
      ),
    );
  }

  Widget _buildDismissible(NoteModel n) {
    return Dismissible(
      key: ValueKey('${n.title}-${n.updatedAt.toIso8601String()}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.push_pin),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (dir) {
        setState(() {
          if (dir == DismissDirection.startToEnd) {
            n.pinned = !n.pinned;
          } else {
            _notes.remove(n);
          }
        });
      },
      child: NoteCard(
        note: n,
        searchQuery: _query,
        onTap: () => _openEditor(n),
        onDelete: () => setState(() => _notes.remove(n)),
        onPinToggle: () => setState(() => n.pinned = !n.pinned),
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
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});
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
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Neu erstellen'),
          ),
        ],
      ),
    );
  }
}

/// ---------- Einfaches Speed-Dial ohne Paket ----------
class FabItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  FabItem({required this.icon, required this.label, required this.onTap});
}

class _FabMenu extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final List<FabItem> items;
  const _FabMenu({required this.open, required this.onToggle, required this.items});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ...items.asMap().entries.map((e) {
        final i = e.key;
        final it = e.value;
        return AnimatedSlide(
          key: ValueKey(it.label),
          duration: const Duration(milliseconds: 220),
          offset: open ? Offset(0, -(i + 1) * 1.2) : const Offset(0, 0),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: open ? 1 : 0,
            child: FloatingActionButton.extended(
              heroTag: 'fab-$i',
              onPressed: () {
                onToggle();
                it.onTap();
              },
              icon: Icon(it.icon),
              label: Text(it.label),
            ),
          ),
        );
      }),
      FloatingActionButton(
        heroTag: 'fab-main',
        onPressed: onToggle,
        child: Icon(open ? Icons.close : Icons.add),
      ),
    ];
    return Stack(
      alignment: Alignment.bottomRight,
      children: children
          .map((w) => Padding(padding: const EdgeInsets.only(bottom: 8, right: 8), child: w))
          .toList(),
    );
  }
}

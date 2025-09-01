import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/note_model.dart';
import '../utils/format.dart';
import '../widgets/editor_toolbar.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteModel note;
  const NoteEditorPage({super.key, required this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleCtrl;
  late quill.QuillController _quillCtrl;
  final _focusNode = FocusNode();

  // Toolbar-Status (für aktive Buttonfarben)
  bool _isBold = false, _isItalic = false, _isUnderline = false, _isStrike = false;
  int _headerLevel = 0;
  String? _listType;   // 'ul' | 'ol'
  String? _blockType;  // 'quote' | 'code'

  quill.Document _docFromDeltaJson(String jsonStr) {
    try {
      return quill.Document.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return quill.Document();
    }
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _quillCtrl = quill.QuillController(
      document: _docFromDeltaJson(widget.note.quillDeltaJson),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillCtrl.addListener(_refreshToolbarState);
    _refreshToolbarState();

    // Markdown in echtes Rich-Text umwandeln (einmalig beim Öffnen)
    _autoConvertMarkdownIfAny();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.removeListener(_refreshToolbarState);
    _quillCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _refreshToolbarState() {
    final s = _quillCtrl.getSelectionStyle().attributes;
    setState(() {
      _isBold = s.containsKey(quill.Attribute.bold.key);
      _isItalic = s.containsKey(quill.Attribute.italic.key);
      _isUnderline = s.containsKey(quill.Attribute.underline.key);
      _isStrike = s.containsKey(quill.Attribute.strikeThrough.key);
      _headerLevel = (s[quill.Attribute.header.key]?.value is int)
          ? (s[quill.Attribute.header.key]!.value as int)
          : 0;
      _listType = s[quill.Attribute.list.key]?.value?.toString();
      _blockType = s[quill.Attribute.blockQuote.key]?.value?.toString() ??
          s[quill.Attribute.codeBlock.key]?.value?.toString();
    });
  }

  // -------- Markdown -> Delta (integriert in die Klasse) --------

  bool _looksLikeMarkdown(String plain) {
    final md = RegExp(
      r'(^\s{0,3}#{1,3}\s)|(\*\*[^*\n]+\*\*)|(^\s*[-*]\s)|(^\s*\d+\.\s)|(^\s*-\s\[[ xX]\]\s)',
      multiLine: true,
    );
    return md.hasMatch(plain);
  }

  List<Map<String, dynamic>> _markdownToDelta(String plain) {
    final ops = <Map<String, dynamic>>[];
    final lines = plain.replaceAll('\r\n', '\n').split('\n');

    // Inline-Parser: **bold**, *italic*, ~~strike~~
    List<Map<String, dynamic>> _inline(String s) {
      final segs = <Map<String, dynamic>>[];
      int i = 0;
      void push(String txt, {Map<String, dynamic>? a}) {
        if (txt.isEmpty) return;
        segs.add(a == null ? {'insert': txt} : {'insert': txt, 'attributes': a});
      }

      while (i < s.length) {
        final locs = <String, int>{
          '**': s.indexOf('**', i),
          '~~': s.indexOf('~~', i),
          '*': s.indexOf('*', i),
        }..removeWhere((_, idx) => idx == -1);

        if (locs.isEmpty) {
          push(s.substring(i));
          break;
        }

        final next = locs.entries.reduce((a, b) => a.value < b.value ? a : b);
        final token = next.key;
        final start = next.value;

        if (start > i) push(s.substring(i, start));

        final end = s.indexOf(token, start + token.length);
        if (end == -1) {
          push(s.substring(start));
          break;
        }

        final inner = s.substring(start + token.length, end);
        switch (token) {
          case '**':
            push(inner, a: {'bold': true});
            break;
          case '*':
            push(inner, a: {'italic': true});
            break;
          case '~~':
            push(inner, a: {'strike': true});
            break;
        }
        i = end + token.length;
      }
      return segs;
    }

    final headerRe = RegExp(r'^\s{0,3}(#{1,3})\s+(.*)$');
    final todoRe = RegExp(r'^\s*-\s\[\s\]\s+(.*)$');
    final doneRe = RegExp(r'^\s*-\s\[x\]\s+(.*)$', caseSensitive: false);
    final ulRe = RegExp(r'^\s*[-*]\s+(.*)$');
    final olRe = RegExp(r'^\s*\d+\.\s+(.*)$');

    for (final raw in lines) {
      final line = raw;

      final hm = headerRe.firstMatch(line);
      if (hm != null) {
        final lvl = hm.group(1)!.length.clamp(1, 3);
        final text = hm.group(2)!;
        ops.addAll(_inline(text));
        ops.add({'insert': '\n', 'attributes': {'header': lvl}});
        continue;
      }

      final td = todoRe.firstMatch(line);
      if (td != null) {
        ops.addAll(_inline(td.group(1)!));
        ops.add({'insert': '\n', 'attributes': {'list': 'unchecked'}});
        continue;
      }
      final dn = doneRe.firstMatch(line);
      if (dn != null) {
        ops.addAll(_inline(dn.group(1)!));
        ops.add({'insert': '\n', 'attributes': {'list': 'checked'}});
        continue;
      }

      final ul = ulRe.firstMatch(line);
      if (ul != null) {
        ops.addAll(_inline(ul.group(1)!));
        ops.add({'insert': '\n', 'attributes': {'list': 'bullet'}});
        continue;
      }
      final ol = olRe.firstMatch(line);
      if (ol != null) {
        ops.addAll(_inline(ol.group(1)!));
        ops.add({'insert': '\n', 'attributes': {'list': 'ordered'}});
        continue;
      }

      ops.addAll(_inline(line));
      ops.add({'insert': '\n'});
    }

    return ops.isEmpty ? [{'insert': '\n'}] : ops;
  }

  void _autoConvertMarkdownIfAny() {
    final plain = _quillCtrl.document.toPlainText();
    if (!_looksLikeMarkdown(plain)) return;

    try {
      final ops = _markdownToDelta(plain);
      final newDoc = quill.Document.fromJson(ops);
      _quillCtrl.removeListener(_refreshToolbarState);
      _quillCtrl = quill.QuillController(
        document: newDoc,
        selection: TextSelection.collapsed(offset: newDoc.length),
      );
      _quillCtrl.addListener(_refreshToolbarState);
      setState(() {}); // Editor neu zeichnen
    } catch (_) {
      // Failsafe: nichts tun, wenn Parser fehlschlägt
    }
  }

  void _save() {
    final deltaJson = jsonEncode(_quillCtrl.document.toDelta().toJson());
    final plain = _quillCtrl.document.toPlainText();
    final preview = firstLineOf(plain);

    Navigator.pop(
      context,
      NoteModel(
        title: _titleCtrl.text.trim().isEmpty ? 'Ohne Titel' : _titleCtrl.text.trim(),
        quillDeltaJson: deltaJson,
        preview: preview,
        template: widget.note.template,
        updatedAt: DateTime.now(),
        pinned: widget.note.pinned,
        colorIndex: widget.note.colorIndex,
        emoji: widget.note.emoji,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notiz bearbeiten'),
        actions: [
          IconButton(
            tooltip: 'Farbe',
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () => setState(() => widget.note.colorIndex = (widget.note.colorIndex + 1) % noteColors.length),
          ),
          IconButton(
            tooltip: widget.note.pinned ? 'Unpin' : 'Pin',
            icon: Icon(widget.note.pinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => widget.note.pinned = !widget.note.pinned),
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Column(
        children: [
          // Titelzeile
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Text(widget.note.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _titleCtrl,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      hintText: 'Titel',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Toolbar mit Smart-Toggle + Fokusweitergabe
          EditorToolbar(
            controller: _quillCtrl,
            focusNode: _focusNode, // falls deine quill-Version das nicht kennt: diese Zeile entfernen
            headerLevel: _headerLevel,
            isBold: _isBold,
            isItalic: _isItalic,
            isUnderline: _isUnderline,
            isStrike: _isStrike,
            listType: _listType,
            blockType: _blockType,
            onHeaderChanged: (lvl) => _headerLevel = lvl,
          ),

          const SizedBox(height: 8),

          // Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: quill.QuillEditor.basic(
                  controller: _quillCtrl,
                  focusNode: _focusNode, // falls inkompatibel, entferne diese Zeile
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

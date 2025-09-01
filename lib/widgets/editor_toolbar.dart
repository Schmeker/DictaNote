import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Toolbar: entfernt Markdown-Zeichen und setzt echtes Rich-Text.
/// - Markierung → säubern + formatieren
/// - Nur Cursor → aktuelles Wort säubern + formatieren
/// - Header/Liste: Zeilen-Prefixe (#, - [ ], 1., -, *) entfernen, dann Block setzen
class EditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final FocusNode? focusNode;

  final int headerLevel;       // 0,1,2,3
  final bool isBold, isItalic, isUnderline, isStrike;
  final String? listType;      // 'ul' | 'ol'
  final String? blockType;     // 'quote' | 'code'
  final ValueChanged<int> onHeaderChanged;

  const EditorToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.headerLevel,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.isStrike,
    required this.listType,
    required this.blockType,
    required this.onHeaderChanged,
  });

  void _focus() { try { focusNode?.requestFocus(); } catch (_) {} }

  ({int start, int end}) _selectionOrWord() {
    final sel = controller.selection;
    final plain = controller.document.toPlainText();
    if (sel.isValid && sel.start != sel.end) return (start: sel.start, end: sel.end);
    final i = sel.baseOffset.clamp(0, plain.length);
    if (plain.isEmpty) return (start: 0, end: 0);
    bool isBoundary(int idx) => idx < 0 || idx >= plain.length || RegExp(r'\s').hasMatch(plain[idx]);
    int s = i, e = i;
    while (s > 0 && !isBoundary(s - 1)) s--;
    while (e < plain.length && !isBoundary(e)) e++;
    return (start: s, end: e);
  }

  ({int lineStart, int lineEnd, String line}) _currentLine() {
    final plain = controller.document.toPlainText();
    final i = controller.selection.baseOffset.clamp(0, plain.length);
    int ls = plain.lastIndexOf('\n', (i - 1).clamp(0, plain.length - 1));
    ls = (ls == -1) ? 0 : ls + 1;
    int le = plain.indexOf('\n', i);
    le = (le == -1) ? plain.length : le;
    return (lineStart: ls, lineEnd: le, line: plain.substring(ls, le));
  }

  void _replace(int index, int len, String replacement, {TextSelection? afterSel}) {
    controller.replaceText(index, len, replacement, afterSel ?? controller.selection);
  }

  ({int start, int end}) _stripInlineMarkdownAround(int start, int end, quill.Attribute attr) {
    final plain = controller.document.toPlainText();
    if (start < 0 || end > plain.length || start >= end) return (start: start, end: end);

    String seg = plain.substring(start, end);
    int removedPrefix = 0, removedSuffix = 0;

    bool removeWrap(String open, String close) {
      if (seg.startsWith(open) && seg.endsWith(close) && seg.length >= open.length + close.length) {
        seg = seg.substring(open.length, seg.length - close.length);
        removedPrefix += open.length; removedSuffix += close.length;
        return true;
      }
      return false;
    }

    if (attr == quill.Attribute.bold) {
      removeWrap('**', '**') || removeWrap('__', '__');
    } else if (attr == quill.Attribute.italic) {
      if (!(seg.startsWith('**') && seg.endsWith('**'))) {
        removeWrap('*', '*') || removeWrap('_', '_');
      }
    } else if (attr == quill.Attribute.strikeThrough) {
      removeWrap('~~', '~~');
    }

    if (removedPrefix + removedSuffix > 0) {
      _replace(
        start, end - start, seg,
        afterSel: TextSelection(baseOffset: start, extentOffset: start + seg.length),
      );
      return (start: start, end: start + seg.length);
    }
    return (start: start, end: end);
  }

  void _stripHeaderAndListPrefixesAtCursor() {
    final lineInfo = _currentLine();
    String line = lineInfo.line;
    final prefix = RegExp(r'^\s{0,3}(#{1,3}\s+)|^(\-\s\[[ xX]\]\s+)|^(\d+\.\s+)|^([*-]\s+)');
    final m = prefix.firstMatch(line);
    if (m != null) {
      final removeLen = m.group(0)!.length;
      _replace(
        lineInfo.lineStart, removeLen, '',
        afterSel: TextSelection(
          baseOffset: controller.selection.baseOffset - removeLen,
          extentOffset: controller.selection.extentOffset - removeLen,
        ),
      );
    }
  }

  void _toggleInline(quill.Attribute attr) {
    _focus();
    final r0 = _selectionOrWord();
    final r1 = _stripInlineMarkdownAround(r0.start, r0.end, attr);
    if (r1.end > r1.start) {
      controller.formatText(r1.start, r1.end - r1.start, attr);
    } else {
      controller.formatSelection(attr);
    }
  }

  void _setHeader(int level) {
    _focus();
    _stripHeaderAndListPrefixesAtCursor();
    final attr = switch (level) {
      0 => quill.Attribute.clone(quill.Attribute.header, null),
      1 => quill.Attribute.h1,
      2 => quill.Attribute.h2,
      _ => quill.Attribute.h3,
    };
    final ln = _currentLine();
    final len = (ln.lineEnd - ln.lineStart) + 1;
    controller.formatText(ln.lineStart, len, attr);
    onHeaderChanged(level);
  }

  void _toggleList(quill.Attribute listAttr) {
    _focus();
    _stripHeaderAndListPrefixesAtCursor();
    final attrs = controller.getSelectionStyle().attributes;
    final same = attrs[listAttr.key]?.value == listAttr.value;
    controller.formatSelection(same ? quill.Attribute.clone(listAttr, null) : listAttr);
  }

  void _toggleBlock(quill.Attribute blockAttr) {
    _focus();
    final attrs = controller.getSelectionStyle().attributes;
    final same = attrs[blockAttr.key]?.value == blockAttr.value;
    controller.formatSelection(same ? quill.Attribute.clone(blockAttr, null) : blockAttr);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color? active(bool on) => on ? cs.primary : null;
    String headLabel = switch (headerLevel) { 0 => 'P', 1 => 'H1', 2 => 'H2', _ => 'H3' };
    Widget gap() => const SizedBox(width: 6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          IconButton(tooltip: 'Undo', onPressed: controller.undo, icon: const Icon(Icons.undo)),
          IconButton(tooltip: 'Redo', onPressed: controller.redo, icon: const Icon(Icons.redo)),
          gap(),
          IconButton(
            tooltip: 'Fett',
            icon: Icon(Icons.format_bold, color: active(isBold)),
            onPressed: () => _toggleInline(quill.Attribute.bold),
          ),
          IconButton(
            tooltip: 'Kursiv',
            icon: Icon(Icons.format_italic, color: active(isItalic)),
            onPressed: () => _toggleInline(quill.Attribute.italic),
          ),
          IconButton(
            tooltip: 'Unterstrichen',
            icon: Icon(Icons.format_underline, color: active(isUnderline)),
            onPressed: () => _toggleInline(quill.Attribute.underline),
          ),
          IconButton(
            tooltip: 'Durchgestrichen',
            icon: Icon(Icons.format_strikethrough, color: active(isStrike)),
            onPressed: () => _toggleInline(quill.Attribute.strikeThrough),
          ),
          gap(),
          PopupMenuButton<int>(
            tooltip: 'Überschrift',
            onSelected: _setHeader,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text('Absatz')),
              PopupMenuItem(value: 1, child: Text('Überschrift 1')),
              PopupMenuItem(value: 2, child: Text('Überschrift 2')),
              PopupMenuItem(value: 3, child: Text('Überschrift 3')),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(headLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          gap(),
          IconButton(
            tooltip: 'Liste •',
            icon: Icon(Icons.format_list_bulleted, color: active(listType == 'ul')),
            onPressed: () => _toggleList(quill.Attribute.ul),
          ),
          IconButton(
            tooltip: 'Liste 1.',
            icon: Icon(Icons.format_list_numbered, color: active(listType == 'ol')),
            onPressed: () => _toggleList(quill.Attribute.ol),
          ),
          gap(),
          IconButton(
            tooltip: 'Zitat',
            icon: Icon(Icons.format_quote, color: active(blockType == 'quote')),
            onPressed: () => _toggleBlock(quill.Attribute.blockQuote),
          ),
          IconButton(
            tooltip: 'Codeblock',
            icon: Icon(Icons.code, color: active(blockType == 'code')),
            onPressed: () => _toggleBlock(quill.Attribute.codeBlock),
          ),
        ]),
      ),
    );
  }
}

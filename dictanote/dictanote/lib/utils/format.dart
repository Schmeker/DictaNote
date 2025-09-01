import 'package:flutter/material.dart';

String firstLineOf(String plain) {
  final line = plain.trim().split('\n').first;
  return line.isEmpty ? '(leer)' : line;
}

String formatDateShort(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
}

/// Erzeugt Text mit Markierung aller Vorkommen von [query] (case-insensitive).
InlineSpan highlightSpan(String text, String query, TextStyle base, TextStyle highlight) {
  if (query.trim().isEmpty) return TextSpan(text: text, style: base);
  final q = query.toLowerCase();
  final t = text;
  final List<TextSpan> spans = [];
  int i = 0;
  while (i < t.length) {
    final idx = t.toLowerCase().indexOf(q, i);
    if (idx < 0) {
      spans.add(TextSpan(text: t.substring(i), style: base));
      break;
    }
    if (idx > i) spans.add(TextSpan(text: t.substring(i, idx), style: base));
    spans.add(TextSpan(text: t.substring(idx, idx + q.length), style: highlight));
    i = idx + q.length;
  }
  return TextSpan(children: spans);
}

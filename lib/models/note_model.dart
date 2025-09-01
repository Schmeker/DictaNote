import 'package:flutter/material.dart';

enum NoteTemplate { blank, todo, meeting, journal }

class NoteModel {
  String title;
  String quillDeltaJson; // Quill Delta als JSON-String
  String preview;        // erste Zeile als Plaintext
  final NoteTemplate template;
  DateTime updatedAt;
  bool pinned;
  int colorIndex;
  String emoji;
  List<String> tags;

  NoteModel({
    required this.title,
    required this.quillDeltaJson,
    required this.preview,
    required this.template,
    DateTime? updatedAt,
    this.pinned = false,
    this.colorIndex = 0,
    this.emoji = '📝',
    List<String>? tags,
  })  : tags = tags ?? <String>[],
        updatedAt = updatedAt ?? DateTime.now();
}

// weiche Akzentfarben für Kartenstreifen
const noteColors = <MaterialColor>[
  Colors.indigo, Colors.teal, Colors.deepOrange,
  Colors.purple, Colors.blueGrey, Colors.cyan,
];

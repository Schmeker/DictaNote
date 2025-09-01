import 'package:flutter/material.dart';

enum NoteTemplate { blank, todo, meeting, journal }

class NoteModel {
  String title;
  String quillDeltaJson; // Rich-Text als Delta JSON (String)
  String preview;        // 1. Zeile Plaintext
  final NoteTemplate template;
  DateTime updatedAt;
  bool pinned;
  int colorIndex;
  String emoji;

  NoteModel({
    required this.title,
    required this.quillDeltaJson,
    required this.preview,
    required this.template,
    DateTime? updatedAt,
    this.pinned = false,
    this.colorIndex = 0,
    this.emoji = '📝',
  }) : updatedAt = updatedAt ?? DateTime.now();
}

// weiche Akzentfarben für Kartenstreifen
const noteColors = <MaterialColor>[
  Colors.indigo, Colors.teal, Colors.deepOrange,
  Colors.purple, Colors.blueGrey, Colors.cyan,
];

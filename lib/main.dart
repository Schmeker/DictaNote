import 'package:flutter/material.dart';
import 'pages/notes_page.dart';

void main() => runApp(const DictaNoteApp());

class DictaNoteApp extends StatelessWidget {
  const DictaNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DictaNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const NotesPage(),
    );
  }
}

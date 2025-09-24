import 'package:Dictanote/views/login_view.dart';
import 'package:flutter/material.dart';

import 'services/database_service.dart';

void main() async {
  final db = await DatabaseService.create();

  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  final DatabaseService db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginView(
        db: db,
      ),
    );
  }
}
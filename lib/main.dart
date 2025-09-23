import 'package:Dictanote/services/database_service.dart';
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'views/home_view.dart';

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
      home: HomePage(
        user: UserModel(
          id: 1,
          username: "joni",
          email: "joniwinter6@gmail.com",
          passwordHash: "123jgbas3213",
          firstname: "Jonathan",
          lastname: "Winter",
        ),
        db: db,
      ),
    );
  }
}
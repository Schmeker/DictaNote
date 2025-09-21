import 'package:Dictanote/models/item_model.dart';
import '../views/home_view.dart';

class ListModel {
  final int id;
  final int ownerId;
  final String title;
  final Template type; // "shopping", "todo", "etc."
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ItemModel> items;

  ListModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    List<ItemModel>? items,
  }) : items = items ?? [];

  List<String> get allowedAttributes {
    switch (type) {
      case Template.shopping:
        return ["title", "description", "completed", "amount"];
      case Template.toDo:
        return ["title", "description", "completed", "priority"]; //TODO: add Timetill in the future;
      case Template.custom:
        return [];
      //default:
        //return ["title"];
    }
  }

  int get listId => id;
}

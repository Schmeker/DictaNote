import '../views/home_view.dart';
import 'item_model.dart';

class UnfinishedListModel {
  final int ownerId;
  final String title;
  final Template type; // "shopping", "todo", "etc."
  final DateTime createdAt;
  DateTime? updatedAt;
  final List<ItemModel> items;

  UnfinishedListModel({
    required this.ownerId,
    required this.title,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    List<ItemModel>? items,
  }) : items = items ?? [];
}
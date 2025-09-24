
class ItemModel {
  final int id;
  final int listId;
  String title;
  String? description;
  bool completed;
  String? amount;
  int? priority;
  DateTime updatedAt;
  DateTime? timeTill;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.completed,
    this.amount,
    this.priority,
    required this.updatedAt,
    this.timeTill,
    required this.createdAt,
  });
}

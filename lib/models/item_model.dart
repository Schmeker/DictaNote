
class ItemModel {
  final int id;
  final int listId;
  String title; //TextField
  String? description; //TextField
  bool completed; // Checkbox, initialised as false
  int? amount; //TextField
  int? priority; //Drop-down 1-5
  DateTime? timeTill; // not implemented
  final DateTime createdAt;
  DateTime updatedAt;

  ItemModel({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    this.completed = false,
    this.amount,
    this.priority,
    this.timeTill,
    required this.createdAt,
    required this.updatedAt,
  });
}

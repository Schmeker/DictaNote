
class UnfinishedItemModel {
  final int listId;
  String title;
  String? description; // Correctly nullable
  String? amount;        // Correctly nullable
  int? priority;      // Correctly nullable
  DateTime updatedAt;
  DateTime? timeTill;   // Correctly nullable
  final DateTime createdAt;

  UnfinishedItemModel({
    required this.listId,
    required this.title,
    this.description,
    this.amount,
    this.priority,
    required this.updatedAt,
    this.timeTill,
    required this.createdAt,
  });
}


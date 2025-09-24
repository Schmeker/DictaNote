
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

  copyWith({String? title, String? description, String? amount, int? priority}) {
    return ItemModel(
      id: id,
      listId: listId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed,
      amount: amount ?? this.amount,
      priority: priority ?? this.priority,
      updatedAt: DateTime.now(),
      timeTill: timeTill,
      createdAt: createdAt,
    );
  }
}

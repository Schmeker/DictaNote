class ListModel {
  final String? id;
  final String ownerId;
  final String title;
  final String type; // e.g., "shopping", "todo", etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  ListModel({
    this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

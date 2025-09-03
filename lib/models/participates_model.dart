class ParticipantModel {
  final int userId;
  final int listId;

  ParticipantModel({
    required this.userId,
    required this.listId,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['user_id'],
      listId: json['list_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'list_id': listId,
    };
  }

}
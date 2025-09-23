import 'package:postgres/postgres.dart';

class ParticipantService {
  final Connection connection;

  ParticipantService(this.connection);

  Future<void> addParticipant(int listId, int userId) async {
    await connection.execute(
      Sql.named('INSERT INTO participates(list_id, user_id) VALUES (@listId, @userId)'),
      parameters: {'listId': listId, 'userId': userId},
    );
  }

  Future<void> removeParticipant(int listId, int userId) async {
    await connection.execute(
      Sql.named('DELETE FROM participates WHERE list_id = @listId AND user_id = @userId'),
      parameters: {'listId': listId, 'userId': userId},
    );
  }
}

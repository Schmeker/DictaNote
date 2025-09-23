import 'package:postgres/postgres.dart';
import '../models/list_model.dart';
import '../models/unfinished_list_model.dart';
import '../views/home_view.dart';

class ListService {
  final Connection connection;

  ListService(this.connection);

  Future<List<ListModel>> getListsForUser(int userId) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM lists WHERE owner_id = @userId'),
      parameters: {'userId': userId},
    );

    return result.map((row) => ListModel(
      id: row[0] as int,
      ownerId: row[1] as int,
      title: row[2] as String,
      type: Template.values[row[3] as int],
      createdAt: row[4] as DateTime,
      updatedAt: row[5] as DateTime,
    )).toList();
  }

  Future<List<ListModel>> getListsForParticipant(int userId) async {
    final result = await connection.execute(
      Sql.named('SELECT l.* FROM participates p '
          'JOIN lists l ON p.list_id = l.id '
          'WHERE p.user_id = @userId'),
      parameters: {'userId': userId},
    );

    return result.map((row) => ListModel(
      id: row[0] as int,
      ownerId: row[1] as int,
      title: row[2] as String,
      type: Template.values[row[3] as int],
      createdAt: row[4] as DateTime,
      updatedAt: row[5] as DateTime,
    )).toList();
  }

  Future<void> addList(UnfinishedListModel list) async {
    await connection.execute(
      Sql.named('INSERT INTO lists(owner_id, title, type, created_at, updated_at) '
          'VALUES (@ownerId, @title, @type, @createdAt, @updatedAt)'),
      parameters: {
        'ownerId': list.ownerId,
        'title': list.title,
        'type': list.type.index,
        'createdAt': list.createdAt,
        'updatedAt': list.updatedAt,
      },
    );
  }

  Future<void> updateList(int listId, String newTitle) async {
    await connection.execute(
      Sql.named('UPDATE lists SET title = @title, updated_at = @updatedAt WHERE id = @id'),
      parameters: {'title': newTitle, 'updatedAt': DateTime.now(), 'id': listId},
    );
  }

  Future<void> deleteList(int listId) async {
    await connection.execute(
      Sql.named('DELETE FROM lists WHERE id = @id'),
      parameters: {'id': listId},
    );
  }
}

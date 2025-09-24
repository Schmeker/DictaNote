import 'package:postgres/postgres.dart';
import '../models/item_model.dart';
import '../models/unfinished_item_model.dart';

class ItemService {
  final Connection connection;

  ItemService(this.connection);

  Future<List<ItemModel>> getItemsForList(int listId) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM items WHERE list_id = @listId'),
      parameters: {'listId': listId},
    );

    return result.map((row) => ItemModel(
      id: row[0] as int,
      listId: row[1] as int,
      title: row[2] as String,
      description: row[3] as String?,
      completed: row[4] as bool,
      amount: row[5] as String?,
      priority: row[6] as int?,
      updatedAt: row[7] as DateTime,
      timeTill: row[8] as DateTime?,
      createdAt: row[9] as DateTime,
    )).toList();
  }

  Future<void> addItem(UnfinishedItemModel item) async {
    await connection.execute(
      Sql.named('INSERT INTO items(list_id, title, description, amount, priority, updated_at, time_till, created_at) '
          'VALUES (@listId, @title, @description, @amount, @priority, @updatedAt, @timeTill, @createdAt)'),
      parameters: {
        'listId': item.listId,
        'title': item.title,
        'description': item.description,
        'amount': item.amount,
        'priority': item.priority,
        'updatedAt': item.createdAt,
        'timeTill': item.timeTill,
        'createdAt': item.createdAt,
      },
    );
  }

  Future<void> updateItem(ItemModel item) async {
    await connection.execute(
      Sql.named('''
      UPDATE items
      SET title = @title,
          description = @description,
          completed = @completed,
          amount = @amount,
          priority = @priority,
          updated_at = @updatedAt,
          time_till = @timeTill
      WHERE id = @id
    '''),
      parameters: {
        'id': item.id,
        'title': item.title,
        'description': item.description,
        'completed': item.completed,
        'amount': item.amount,
        'priority': item.priority,
        'updatedAt': DateTime.now(),
        'timeTill': item.timeTill,
      },
    );
    await connection.execute(
      Sql.named('UPDATE lists SET updated_at = @updatedAt WHERE id = @listId'),
      parameters: {'listId': item.listId, 'updatedAt': DateTime.now()},
    );
  }


  Future<void> deleteItem(int itemId) async {
    await connection.execute(
      Sql.named('DELETE FROM items WHERE id = @itemId'),
      parameters: {'itemId': itemId},
    );
  }
}
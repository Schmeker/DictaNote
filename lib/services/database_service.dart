import 'package:postgres/postgres.dart';

import 'item_service.dart';
import 'list_service.dart';
import 'user_service.dart';
import 'participates_service.dart';


class DatabaseService {
  late final Connection connection;
  late final ItemService items;
  late final ListService lists;
  late final UserService users;
  late final ParticipantService participants;

  DatabaseService._(this.connection) {
    items = ItemService(connection);
    lists = ListService(connection);
    users = UserService(connection);
    participants = ParticipantService(connection);
  }

  static Future<DatabaseService> create() async {
    final conn = await Connection.open(Endpoint(
      host: '192.168.178.57',
      database: 'dictanote',
      username: 'jonathan',
      password: 'raspberry',
    ));
    return DatabaseService._(conn);
  }
}

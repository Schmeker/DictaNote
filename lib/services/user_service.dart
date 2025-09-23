import 'package:postgres/postgres.dart';
import '../models/user_model.dart';
import '../models/unfinished_user_model.dart';

class UserService {
  final Connection connection;

  UserService(this.connection);

  Future<void> addUser(UnfinishedUserModel user) async {
    await connection.execute(
      Sql.named('INSERT INTO users(username, email, password_hash, firstname, lastname) '
          'VALUES (@username, @email, @password_hash, @firstname, @lastname)'),
      parameters: {
        'username': user.username,
        'email': user.email,
        'password_hash': user.passwordHash,
        'firstname': user.firstname,
        'lastname': user.lastname,
      },
    );
  }

  Future<void> updateUser(int userId, {String? email, String? firstname, String? lastname}) async {
    await connection.execute(
      Sql.named('UPDATE users SET email = COALESCE(@email,email), firstname = COALESCE(@firstname,firstname), lastname = COALESCE(@lastname,lastname) WHERE id = @id'),
      parameters: {
        'id': userId,
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
      },
    );
  }

  Future<void> deleteUser(int userId) async {
    await connection.execute(
      Sql.named('DELETE FROM users WHERE id = @id'),
      parameters: {'id': userId},
    );
  }
}

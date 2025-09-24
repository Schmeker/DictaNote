import 'package:postgres/postgres.dart';
import '../models/user_model.dart';
import '../models/unfinished_user_model.dart';

class UserService {
  final Connection connection;

  UserService(this.connection);

  Future<void> addUser(UnfinishedUserModel user) async {
    await connection.execute(
      Sql.named('INSERT INTO users(username, email, password_hash) '
          'VALUES (@username, @email, @password_hash)'),
      parameters: {
        'username': user.username,
        'email': user.email,
        'password_hash': user.passwordHash,
      },
    );
  }

  Future<void> updateUser(int userId, {String? email, String? username}) async {
    await connection.execute(
      Sql.named(      'UPDATE users SET email = COALESCE(@email, email), username = COALESCE(@username, username) WHERE id = @id'),
      parameters: {
        'id': userId,
        'email': email,
        'username': username,
      },
    );
  }

  Future<bool> emailExists(String email) async {
    final result = await connection.execute(
      Sql.named('SELECT COUNT(*) FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    final count = result.first[0] as int;
    return count > 0;
  }

  Future<UserModel?> getUserByEmailPassword(String email, String passwordHash) async {
    print(passwordHash);
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email AND password_hash = @password_hash LIMIT 1'),
      parameters: {
        'email': email,
        'password_hash': passwordHash,
      },
    );

    final row = result.first;
    return UserModel(
      id: row[0] as int,
      username: row[1] as String,
      email: row[2] as String,
      passwordHash: row[3] as String,
    );
  }

  Future<void> deleteUser(int userId) async {
    await connection.execute(
      Sql.named('DELETE FROM users WHERE id = @id'),
      parameters: {'id': userId},
    );
  }
}

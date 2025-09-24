
class UserModel {
  final int id;
  final String username;
  final String email;
  final String passwordHash;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  UserModel copyWith({
     int? id,
     String? username,
     String? email,
  })
  {return UserModel(
     id: id ?? this.id,
     username: username ?? this.username,
     email: email ?? this.email,
     passwordHash: passwordHash,
    );
  }
}
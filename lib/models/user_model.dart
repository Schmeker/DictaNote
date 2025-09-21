
class UserModel {
  final int id;
  final String username;
  final String email;
  final String passwordHash;
  final String firstname;
  final String lastname;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.firstname,
    required this.lastname,
  });
}
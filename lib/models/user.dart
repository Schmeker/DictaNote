import 'package:flutter/material.dart';

class UserModel {
  final String? id;
  final String username;
  final String email;
  final String passwordHash;
  final String firstname;
  final String lastname;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.firstname,
    required this.lastname,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      passwordHash: json['password_hash'],
      firstname: json['firstname'],
      lastname: json['lastname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'firstname': firstname,
      'lastname': lastname,
    };
  }
}

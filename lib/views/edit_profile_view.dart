import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  final DatabaseService db;

  const EditProfileView({super.key, required this.user, required this.db});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  String? _validateUsername(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Username cannot be empty';
    if (v.length < 3) return 'Username must be at least 3 characters';
    if (v.length > 20) return 'Username cannot exceed 20 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newUsername = _usernameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();

    try {
      if (newEmail != widget.user.email &&
          await widget.db.users.emailExists(newEmail)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already registered by another user.')),
          );
        }
        return;
      }

      final updatedUser = widget.user.copyWith(
        username: newUsername,
        email: newEmail,
      );

      await widget.db.users.updateUser(updatedUser.id, username: newUsername, email: newEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(updatedUser); // Return updated user to HomePage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: _validateUsername,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

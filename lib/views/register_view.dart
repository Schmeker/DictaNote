import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/unfinished_user_model.dart';
import '../services/database_service.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  final DatabaseService db;


  const RegisterView({super.key, required this.db});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _obscurePw = true;

  String? _validateUsername(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Username cannot be empty';
    if (v.length < 3) return 'Username must be at least 3 characters';
    if (v.length > 20) return 'Username cannot exceed 20 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter an email address';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Invalid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter a password';
    if ((value ?? '').length < 6) return 'Password must be at least 6 characters long';
    if ((value ?? '').length > 20) return 'Password cannot exceed 20 characters';
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (await widget.db.users.emailExists(_emailCtrl.text.trim())) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child:Text('Email already exists. Please use a different email.'),)),
            );
          }
          return;
        }

        final hashedPassword = sha256.convert(utf8.encode(_pwCtrl.text)).toString();

        final newUser = UnfinishedUserModel(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          passwordHash: hashedPassword,
        );

        await widget.db.users.addUser(newUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please log in.')),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginView(db: widget.db)),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text('Registration failed: $e.'),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your new account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 72),
                Text(
                  'Create your new account',
                ),
                const SizedBox(height: 24),

                // username
                TextFormField(
                  controller: _usernameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validateUsername
                ),
                const SizedBox(height: 12),

                // E-Mail
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),

                // password
                TextFormField(
                  controller: _pwCtrl,
                  obscureText: _obscurePw,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePw ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePw = !_obscurePw),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),

                // register button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _register,
                    child: const Text('register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

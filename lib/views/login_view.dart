import 'dart:convert';

import 'package:Dictanote/views/home_view.dart';
import 'package:Dictanote/views/register_view.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';


import '../models/user_model.dart';
import '../services/database_service.dart';

class LoginView extends StatefulWidget {
  final DatabaseService db;

  const LoginView({super.key, required this.db});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscurePw = true;

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter an email address';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter a password';
    if ((value ?? '').length < 6) return 'Password must be at least 6 characters long';
    if ((value ?? '').length > 20) return 'Password cannot exceed 20 characters';
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final hashedPassword = sha256.convert(utf8.encode(_pwCtrl.text)).toString();

        print(hashedPassword);

        final UserModel? user = await widget.db.users.getUserByEmailPassword(
          _emailCtrl.text,
          hashedPassword,
        );

        if (user != null &&
            mounted) {
          Navigator
              .pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: user, db: widget.db),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid email or password')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text('Login failed: $e')
              ),
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final maxFormWidth = isWide ? 420.0 : double.infinity;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Welcome back',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please sign in to continue',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Formular
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'E-Mail',
                                hintText: 'name@beispiel.de',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pwCtrl,
                              obscureText: _obscurePw,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePw
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                      _obscurePw ? Icons.visibility : Icons
                                          .visibility_off),
                                  onPressed: () =>
                                      setState(() => _obscurePw = !_obscurePw),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: _login,
                                child: const Text('Sign in'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider + Register
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('or'),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterView(db: widget.db)
                                )
                            ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Create new account'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final m = context.read<UsersModel>();
    final ok = await m.create(
      User.draft(
        name: _name.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
      ),
    );
    if (!mounted) return; // State uses `mounted`
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final e = m.saveError;
      final text = switch (e) {
        ServerException(:final status) => 'Server error $status',
        NoConnectionException() => 'No connection',
        _ => 'Could not save the user',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<UsersModel>().saving;
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Enter a username';
                  if (s.contains(' ')) return 'No spaces';
                  return null;
                },
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
                      ? null
                      : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                // disabled while the request is in flight
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

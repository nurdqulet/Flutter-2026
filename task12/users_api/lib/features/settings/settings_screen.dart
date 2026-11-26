import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;

    // all cities of the loaded users, without duplicates
    final citySet = <String>{};
    for (final u in users) {
      citySet.add(u.address.city);
    }
    // the saved city must be in the list, even before the users are loaded
    final saved = s.city;
    if (saved != null) citySet.add(saved);
    final cities = citySet.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: (v) => unawaited(s.setDark(v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String?>(
              initialValue: s.city,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (c) => unawaited(s.setCity(c)),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              final auth = context.read<AuthModel>();
              final nav = Navigator.of(context);
              await auth.logout();
              nav.popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

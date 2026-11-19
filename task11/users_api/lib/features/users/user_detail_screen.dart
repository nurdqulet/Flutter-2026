import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row('Username', user.username),
          _row('Email', user.email),
          // taps do nothing yet: Practice 12 adds url_launcher
          ListTile(
            title: Text(user.phone),
            subtitle: const Text('Phone'),
            onTap: () {},
          ),
          ListTile(
            title: Text(user.website ?? '—'),
            subtitle: const Text('Website'),
            onTap: () {},
          ),
          _row(
            'Address',
            '${user.address.street}, ${user.address.suite}\n'
                '${user.address.city}, ${user.address.zipcode}',
          ),
          _row('Geo', '${user.address.geo.lat}, ${user.address.geo.lng}'),
          _row('Company', '${user.company.name}\n${user.company.catchPhrase}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) =>
      ListTile(title: Text(value), subtitle: Text(label));
}

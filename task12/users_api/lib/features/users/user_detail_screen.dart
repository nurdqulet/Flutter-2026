import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final site = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row('Username', user.username),
          ListTile(
            title: Text(user.email),
            subtitle: const Text('Email'),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            title: Text(user.phone),
            subtitle: const Text('Phone'),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            title: Text(site ?? '—'),
            subtitle: const Text('Website'),
            onTap: site == null
                ? null
                : () => _open(context, Uri.parse('https://$site')),
          ),
          _row(
            'Address',
            '${user.address.street}, ${user.address.suite}\n'
                '${user.address.city}, ${user.address.zipcode}',
          ),
          _row('Geo', '${user.address.geo.lat}, ${user.address.geo.lng}'),
          _row('Company', '${user.company.name}\n${user.company.catchPhrase}'),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy token to clipboard'),
              onTap: () => _copyToken(context),
            ),
        ],
      ),
    );
  }

  /// launchUrl answers false when no app can open the link.
  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } on PlatformException {
      ok = false;
    }
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No app can open this')),
      );
    }
  }

  Future<void> _copyToken(BuildContext context) async {
    final store = context.read<SecureStore>();
    final messenger = ScaffoldMessenger.of(context);
    final token = await store.readToken();
    if (token == null) {
      messenger.showSnackBar(const SnackBar(content: Text('No token')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    messenger.showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  Widget _row(String label, String value) =>
      ListTile(title: Text(value), subtitle: Text(label));
}

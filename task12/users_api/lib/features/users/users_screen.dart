import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        child: const Icon(Icons.add),
      ),
      body: _body(m, city),
    );
  }

  Widget _body(UsersModel m, String? city) {
    // first load: a spinner. While refreshing, the list stays on screen.
    if (m.loading && m.items.isEmpty) return const LoadingView();

    // exhaustive: ApiException is sealed, so there is no default
    return switch (m.error) {
      null => Column(
        children: [
          if (m.fromCache) StaleBanner(onRetry: m.load),
          Expanded(
            child: UserList(
              users: city == null
                  ? m.items
                  : [
                      for (final u in m.items)
                        if (u.address.city == city) u,
                    ],
              onRefresh: m.load,
            ),
          ),
        ],
      ),
      NoConnectionException() => ErrorView(text: 'Offline', onRetry: m.load),
      NotFoundException() || UnauthorizedException() => ErrorView(
        text: 'Not found or not allowed',
        onRetry: m.load,
      ),
      ServerException(:final status) => ErrorView(
        text: 'Server error $status',
        onRetry: m.load,
      ),
      BadResponseException() => const ErrorView(
        text: 'We could not read the answer',
      ),
    };
  }
}

/// Shown only when the list comes from the saved file.
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      leading: const Icon(Icons.cloud_off),
      content: const Text('Saved data · no connection'),
      actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.text, this.onRetry});

  final String text;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 8),
          Text(text),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.users, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email} · ${u.address.city}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}

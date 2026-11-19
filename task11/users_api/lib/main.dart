import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

// The composition root: the only file that says http.Client().
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final model = UsersModel(UserRepository(ApiClient(http.Client())));
        unawaited(model.load());
        return model;
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const UsersScreen(),
    );
  }
}

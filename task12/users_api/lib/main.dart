import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

// The composition root: the only file that says http.Client().
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin

  // Read from disk BEFORE runApp: the first frame already has the right theme.
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter'); // String?

  const store = SecureStore();
  final token = await store.readToken();

  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(UserRepository(api, UsersCache()));
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    final signedIn = context.watch<AuthModel>().signedIn;
    return MaterialApp(
      title: 'Users',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}

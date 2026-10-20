import 'package:flutter/material.dart';

import 'models/photo_event.dart';
import 'route_arguments.dart';
import 'routes.dart';
import 'screens/app_shell.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    if (settings.name == Routes.detail && arguments is EventDetailArguments) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => EventDetailScreen(arguments: arguments),
      );
    }

    if (settings.name == Routes.form && arguments is EventFormArguments) {
      return MaterialPageRoute<PhotoEvent>(
        settings: settings,
        builder: (context) => EventFormScreen(event: arguments.event),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final seedColor = ThemeData.light().colorScheme.primary;

    return MaterialApp(
      title: 'PhotoMeet',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) =>
            AppShell(themeMode: _themeMode, onThemeChanged: _changeTheme),
      },
      onGenerateRoute: _generateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(
            child: Text('The requested screen was not found.'),
          ),
        ),
      ),
    );
  }
}

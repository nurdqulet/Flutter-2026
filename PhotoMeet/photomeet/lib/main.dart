import 'package:flutter/material.dart';

import 'data/seed_data.dart';
import 'models/photo_event.dart';
import 'widgets/event_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ThemeData.light().colorScheme.primary,
        ),
        useMaterial3: true,
      ),
      home: const EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<PhotoEvent> _events = createSeedEvents();

  void _toggleFavourite(PhotoEvent event) {
    setState(() {
      _events = _events
          .map(
            (current) => current.id == event.id
                ? current.copyWith(favourite: !current.favourite)
                : current,
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PhotoMeet')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final event = _events[index];

          return EventCard(
            key: ValueKey(event.id),
            event: event,
            onFavourite: () => _toggleFavourite(event),
          );
        },
      ),
    );
  }
}

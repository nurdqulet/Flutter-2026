import 'package:flutter/material.dart';

import 'data/seed_data.dart';
import 'models/photo_event.dart';
import 'utils/format.dart';

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
  final List<PhotoEvent> _events = createSeedEvents();

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
          final date = event.when;
          final (:taken, :free) = event.places;

          return Card(
            child: ListTile(
              leading: Icon(
                event.category.icon,
                color: event.category.color(Theme.of(context).colorScheme),
              ),
              title: Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  if (date != null) formatDateTime(date),
                  event.place,
                  '$taken registered · $free free',
                ].join('\n'),
              ),
              isThreeLine: true,
              trailing: Icon(
                event.favourite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          );
        },
      ),
    );
  }
}

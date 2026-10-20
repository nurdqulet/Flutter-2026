import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/photo_event.dart';
import '../models/profile.dart';
import '../widgets/event_card.dart';
import 'profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<PhotoEvent> _events = createSeedEvents();
  Profile _profile = const Profile.empty();
  int _selectedTab = 0;

  void _selectTab(int index) {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedTab = index;
    });
  }

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

  void _updateProfile(Profile profile) {
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favourites = _events.where((event) => event.favourite).toList();

    final joinedCount = _events
        .where(
          (event) => _profile.name.isNotEmpty && event.contains(_profile.name),
        )
        .length;

    final titles = ['PhotoMeet', 'Favourites', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedTab])),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _EventListTab(
            events: _events,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No events yet',
          ),
          _EventListTab(
            events: favourites,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No favourites yet. Tap a heart to add one.',
          ),
          ProfileTab(
            profile: _profile,
            joinedCount: joinedCount,
            themeMode: widget.themeMode,
            onProfileChanged: _updateProfile,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(Icons.photo_camera),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _EventListTab extends StatelessWidget {
  const _EventListTab({
    required this.events,
    required this.onFavourite,
    required this.emptyMessage,
  });

  final List<PhotoEvent> events;
  final ValueChanged<PhotoEvent> onFavourite;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];

        return EventCard(
          key: ValueKey(event.id),
          event: event,
          onFavourite: () => onFavourite(event),
        );
      },
    );
  }
}

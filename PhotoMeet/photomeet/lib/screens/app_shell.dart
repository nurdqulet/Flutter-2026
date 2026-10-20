import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/photo_event.dart';
import '../models/profile.dart';
import 'events_tab.dart';
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
          EventsTab(
            events: _events,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No events yet',
          ),
          EventsTab(
            events: favourites,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No favourites yet. Tap a heart to add one.',
            showFilters: false,
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

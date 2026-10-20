import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/photo_event.dart';
import '../models/profile.dart';
import '../utils/dialogs.dart';
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
  int _resetVersion = 0;

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

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About PhotoMeet'),
          content: const Text(
            'PhotoMeet helps you discover and join photography '
            'walks and workshops.\n\n'
            'Browse events, save favourites and manage your profile.\n\n'
            'All data is stored in memory and resets when the '
            'application restarts.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData() async {
    final confirmed = await confirmAction(
      context,
      title: 'Reset data?',
      message:
          'Restore the original events and clear your profile? '
          'Your current changes will be lost.',
      actionLabel: 'Reset',
    );

    if (!mounted) {
      return;
    }

    if (confirmed != true) {
      return;
    }

    setState(() {
      _events = createSeedEvents();
      _profile = const Profile.empty();
      _selectedTab = 0;
      _resetVersion++;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data reset')));
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_camera, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'PhotoMeet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text('Photography walks and workshops'),
                  ],
                ),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          EventsTab(
            key: ValueKey('events-$_resetVersion'),
            events: _events,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No events yet',
          ),
          EventsTab(
            key: ValueKey('favourites-$_resetVersion'),
            events: favourites,
            onFavourite: _toggleFavourite,
            emptyMessage: 'No favourites yet. Tap a heart to add one.',
            showFilters: false,
          ),
          ProfileTab(
            key: ValueKey('profile-$_resetVersion'),
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

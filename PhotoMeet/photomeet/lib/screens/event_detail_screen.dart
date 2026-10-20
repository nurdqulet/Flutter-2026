import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/photo_event.dart';
import '../route_arguments.dart';
import '../routes.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.arguments});

  final EventDetailArguments arguments;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late PhotoEvent _event;
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _event = widget.arguments.event;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _applyEvent(PhotoEvent event) {
    setState(() {
      _event = event;
      _now = DateTime.now();
    });

    widget.arguments.onChanged(event);
  }

  Future<void> _editEvent() async {
    final result = await Navigator.pushNamed<PhotoEvent>(
      context,
      Routes.form,
      arguments: EventFormArguments(event: _event),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      return;
    }

    _applyEvent(result);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Event updated')));
  }

  Future<void> _toggleRegistration() async {
    final name = widget.arguments.profile.name.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in Profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.arguments.onProfileRequested,
          ),
        ),
      );
      return;
    }

    if (_event.contains(name)) {
      _applyEvent(
        _event.copyWith(
          names: _event.names.where((current) => current != name).toList(),
        ),
      );
      return;
    }

    if (_event.isFull || _event.isPast) {
      return;
    }

    final confirmed = await confirmAction(
      context,
      title: 'Register?',
      message: 'Join "${_event.title}" as $name?',
      actionLabel: 'Register',
    );

    if (!mounted) {
      return;
    }

    if (confirmed != true) {
      return;
    }

    // The event may have started while the dialog was open.
    if (_event.isFull || _event.isPast) {
      setState(() {
        _now = DateTime.now();
      });
      return;
    }

    _applyEvent(_event.copyWith(names: [..._event.names, name]));
  }

  Future<void> _deleteEvent() async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete event?',
      message: 'Delete "${_event.title}"?',
      actionLabel: 'Delete',
    );

    if (!mounted) {
      return;
    }

    if (confirmed != true) {
      return;
    }

    widget.arguments.onDeleted(_event.id);
    Navigator.pop(context);
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countdown = Countdown.from(_event.when, _now);

    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/event_header.jpg', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: scheme.surface,
              child: Icon(
                _event.category.icon,
                size: 32,
                color: _event.category.color(scheme),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Chip(
                    label: Text(
                      _event.category.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Chip(
                    label: Text(
                      countdownLabel(countdown),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    final date = _event.when;
    final description = _event.description;
    final (:taken, :free) = _event.places;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_event.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (date != null) Text('Date: ${formatDateTime(date)}'),
        const SizedBox(height: 8),
        Text('${_event.online ? 'Link' : 'Place'}: ${_event.place}'),
        const SizedBox(height: 8),
        Text('Category: ${_event.category.label}'),
        const SizedBox(height: 8),
        Text('Registered: $taken / ${_event.limit}'),
        const SizedBox(height: 8),
        Text('Free places: $free'),
        if (description != null) ...[
          const SizedBox(height: 16),
          Text(description),
        ],
      ],
    );
  }

  Widget _buildParticipants(BuildContext context) {
    if (_event.names.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has registered yet.',
      );
    }

    final profileName = widget.arguments.profile.name;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _event.names.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final name = _event.names[index];
        final isYou = name == profileName;

        return ListTile(
          title: Text(
            isYou ? '$name (You)' : name,
            style: isYou
                ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final registered = _event.contains(widget.arguments.profile.name);
    final cannotRegister = !registered && (_event.isFull || _event.isPast);

    final actionLabel = registered
        ? 'Cancel registration'
        : _event.isPast
        ? 'Event has started'
        : _event.isFull
        ? 'Event is full'
        : 'Register';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editEvent();
                    break;
                  case 'delete':
                    _deleteEvent();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(context),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Participants (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_buildAbout(context), _buildParticipants(context)],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: cannotRegister ? null : _toggleRegistration,
              child: Text(actionLabel),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'models/photo_event.dart';
import 'models/profile.dart';

class EventDetailArguments {
  const EventDetailArguments({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onProfileRequested,
  });

  final PhotoEvent event;
  final Profile profile;
  final ValueChanged<PhotoEvent> onChanged;
  final ValueChanged<String> onDeleted;
  final VoidCallback onProfileRequested;
}

class EventFormArguments {
  const EventFormArguments({this.event});

  final PhotoEvent? event;
}

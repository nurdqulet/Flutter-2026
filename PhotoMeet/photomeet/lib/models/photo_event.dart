import 'package:flutter/material.dart';

enum EventCategory {
  street('Street', Icons.location_city),
  portrait('Portrait', Icons.person),
  nature('Nature', Icons.park),
  studio('Studio', Icons.photo_camera),
  editing('Editing', Icons.tune);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.street => scheme.primary,
    EventCategory.portrait => scheme.secondary,
    EventCategory.nature => scheme.tertiary,
    EventCategory.studio => scheme.primaryContainer,
    EventCategory.editing => scheme.secondaryContainer,
  };
}

class PhotoEvent {
  factory PhotoEvent({
    required String id,
    required String title,
    required EventCategory category,
    required DateTime when,
    required String place,
    required int limit,
    List<String> names = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) {
    return PhotoEvent._(
      id: id,
      title: title,
      category: category,
      when: when,
      place: place,
      limit: limit,
      names: List<String>.unmodifiable(names),
      online: online,
      description: description,
      favourite: favourite,
    );
  }

  const PhotoEvent._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    required this.names,
    required this.online,
    required this.description,
    required this.favourite,
  });

  const PhotoEvent.empty()
    : id = '',
      title = '',
      category = EventCategory.street,
      when = null,
      place = '',
      limit = 10,
      names = const [],
      online = false,
      description = null,
      favourite = false;

  final String id;
  final String title;
  final EventCategory category;
  final DateTime? when;
  final String place;
  final int limit;
  final List<String> names;
  final bool online;
  final String? description;
  final bool favourite;

  int get count => names.length;

  int get freePlaces => limit - count;

  bool get isFull => count >= limit;

  bool get isPast {
    final date = when;
    return date != null && date.isBefore(DateTime.now());
  }

  bool contains(String name) => names.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  PhotoEvent copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? names,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return PhotoEvent._(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      place: place ?? this.place,
      limit: limit ?? this.limit,
      names: List<String>.unmodifiable(names ?? this.names),
      online: online ?? this.online,
      description: clearDescription ? null : description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}

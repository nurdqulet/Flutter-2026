import '../models/photo_event.dart';

List<PhotoEvent> createSeedEvents() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 14);

  PhotoEvent event(
    String id,
    String title,
    EventCategory category,
    int days, {
    String place = 'Central Park',
    int limit = 10,
    List<String> names = const [],
    bool online = false,
    String? description = 'Bring your camera or smartphone.',
    bool favourite = false,
  }) {
    return PhotoEvent(
      id: id,
      title: title,
      category: category,
      when: tomorrow.add(Duration(days: days)),
      place: place,
      limit: limit,
      names: names,
      online: online,
      description: description,
      favourite: favourite,
    );
  }

  return [
    event(
      '1',
      'Golden hour street photography walk around the old city park',
      EventCategory.street,
      0,
      names: ['Amina', 'Dias'],
      favourite: true,
    ),
    event(
      '2',
      'Portrait basics',
      EventCategory.portrait,
      1,
      place: 'Photo Studio A',
      limit: 3,
      names: ['Amina', 'Dias', 'Arman'],
    ),
    event(
      '3',
      'Last weekend photo walk',
      EventCategory.street,
      -3,
      place: 'Old Town',
      names: ['Dana'],
    ),
    event(
      '4',
      'Online editing workshop',
      EventCategory.editing,
      2,
      place: 'https://meet.example.com/editing',
      online: true,
      limit: 20,
    ),
    event(
      '5',
      'Quiet morning in nature',
      EventCategory.nature,
      3,
      place: 'Botanical Garden',
      description: null,
    ),
    event(
      '6',
      'Studio lighting practice',
      EventCategory.studio,
      4,
      place: 'Photo Studio B',
      limit: 6,
      names: ['Miras', 'Dana'],
      favourite: true,
    ),
    event(
      '7',
      'City architecture walk',
      EventCategory.street,
      5,
      place: 'City Centre',
      limit: 15,
    ),
    event(
      '8',
      'Natural light portraits',
      EventCategory.portrait,
      6,
      place: 'Riverside',
      names: ['Amina'],
    ),
    event(
      '9',
      'Forest photo adventure',
      EventCategory.nature,
      7,
      place: 'Forest Entrance',
      limit: 8,
      names: ['Dias', 'Dana', 'Miras', 'Arman'],
    ),
    event(
      '10',
      'Product photography',
      EventCategory.studio,
      8,
      place: 'Photo Studio A',
      limit: 5,
    ),
    event(
      '11',
      'Colour editing practice',
      EventCategory.editing,
      9,
      place: 'Creative Hub',
      limit: 12,
      favourite: true,
    ),
    event(
      '12',
      'Evening river reflections',
      EventCategory.nature,
      10,
      place: 'River Bridge',
      limit: 8,
      names: ['Dana', 'Arman'],
    ),
  ];
}

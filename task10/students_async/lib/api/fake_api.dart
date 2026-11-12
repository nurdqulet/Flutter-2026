import 'package:flutter/foundation.dart';

class Student {
  const Student({
    required this.name,
    required this.group,
    this.gpa,
  });

  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});

  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran
  int _saveCalls = 0; // how many times save() ran

  Future<List<Student>> fetchStudents() async {
    calls++;
    final call = calls; // remember our own number: calls may grow while we wait
    debugPrint('fetchStudents #$call');
    await Future.delayed(const Duration(seconds: 2));
    if (call % 3 == 0) {
      throw NoConnectionException(); // every third request fails
    }
    return empty ? const <Student>[] : _seed;
  }

  // Level 5 needs it: waits one second, rejects every second call.
  Future<void> save(int value) async {
    _saveCalls++;
    final call = _saveCalls;
    await Future.delayed(const Duration(seconds: 1));
    if (call % 2 == 0) {
      throw StateError('server rejected $value');
    }
  }
}

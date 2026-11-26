import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

/// The last good list, kept in Documents (Temporary is temporary).
class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  /// null when there is no file or it cannot be read.
  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final body = jsonDecode(await file.readAsString());
      if (body is! List) return null;
      return [
        for (final item in body) User.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

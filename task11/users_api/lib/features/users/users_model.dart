import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

/// Holds loading / error / items. Not a State, not a repository:
/// no BuildContext, no mounted, no http.
class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;

  // the "New user" form
  bool saving = false;
  ApiException? saveError;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns true if the user was created. On failure [saveError] is set.
  Future<bool> create(User draft) async {
    if (saving) return false; // a double tap sends one request
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
      return true;
    } on ApiException catch (e) {
      saveError = e;
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}

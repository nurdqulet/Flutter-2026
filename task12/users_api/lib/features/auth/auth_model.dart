import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? token}) : _signedIn = token != null;

  final SecureStore _store;
  bool _signedIn;

  bool get signedIn => _signedIn;

  /// The fake: any password of 8+ characters works, after one second.
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) throw const FormatException('password too short');
    await _store.saveToken('tok_${email.hashCode}');
    _signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _signedIn = false;
    notifyListeners();
  }
}

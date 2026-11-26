import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dark mode and the city filter. Initial values are read in main()
/// before runApp, so the first frame already has the right theme.
class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this._dark, this._city});

  final SharedPreferencesAsync _prefs;

  bool _dark;
  String? _city;

  bool get dark => _dark;
  String? get city => _city;

  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners(); // the screen does not wait for the disk
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    _city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }
}

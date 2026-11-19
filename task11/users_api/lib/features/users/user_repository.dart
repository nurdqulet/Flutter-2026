import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

/// The only class (with ApiClient) that knows http exists.
/// The screens get [User]s or an [ApiException], never a Response or a Map.
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final http.Response r = await _api.get(Uri.https(_api.host, '/users'));
    final body = _api.decode(r);
    return _parse('users', () {
      if (body is! List) throw const FormatException('expected a list');
      return [for (final item in body) User.fromJson(item as Map<String, dynamic>)];
    });
  }

  Future<User> getById(int id) async {
    final http.Response r = await _api.get(Uri.https(_api.host, '/users/$id'));
    final body = _api.decode(r);
    return _parse('users/$id', () => User.fromJson(body as Map<String, dynamic>));
  }

  Future<User> create(User draft) async {
    final http.Response r = await _api.post(
      Uri.https(_api.host, '/users'),
      draft.toJson(),
    );
    if (r.statusCode != 201) {
      throw BadResponseException('POST users: expected 201, got ${r.statusCode}');
    }
    final body = _api.decode(r);
    return _parse('POST users', () => User.fromJson(body as Map<String, dynamic>));
  }

  // A failed cast (TypeError) or a bad number (FormatException) inside
  // fromJson becomes our own exception that names the place.
  T _parse<T>(String where, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}

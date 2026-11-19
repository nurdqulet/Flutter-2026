import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// The only place that talks to the network.
/// Every failure leaves this class as an [ApiException].
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  // Headers in one place.
  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<http.Response> get(Uri uri) async {
    final response = await _send(() => _client.get(uri, headers: _headers));
    _check(response);
    return response;
  }

  Future<http.Response> post(Uri uri, Object body) async {
    final response = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(response);
    return response;
  }

  /// Turns the body into Dart objects. A broken body is [BadResponseException].
  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: $e');
    }
  }

  // 1. Send with a 10-second timeout. No answer at all = NoConnection.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url} '
          '-> ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  // 2. Look at the status BEFORE the body.
  void _check(http.Response r) {
    final code = r.statusCode;
    if (code == 401) throw const UnauthorizedException();
    if (code == 404) throw const NotFoundException();
    if (code >= 500) throw ServerException(code);
    if (code >= 400) throw BadResponseException('status $code');
  }
}

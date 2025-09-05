import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

class FirebaseBackend {
  final String apiKey;
  final String projectId;
  final http.Client _client = BrowserClient();

  String? _idToken;
  String? _uid;

  FirebaseBackend({required this.apiKey, required this.projectId});

  
  Future<void> signInAnonymously() async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    final resp = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"returnSecureToken": true}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Auth failed: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    _idToken = data['idToken'];
    _uid = data['localId'];
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );
    final resp = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Auth failed: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    _idToken = data['idToken'];
    _uid = data['localId'];
  }

  String get _baseDbUrl =>
      'https://$projectId-default-rtdb.firebaseio.com';

  Future<Map<String, dynamic>> getWeather() async {
    final url = Uri.parse('$_baseDbUrl/weather.json?auth=$_idToken');
    final resp = await _client.get(url);
    if (resp.statusCode != 200) {
      throw Exception('GET weather failed: ${resp.statusCode} ${resp.body}');
    }
    final body = resp.body.isEmpty ? '{}' : resp.body;
    return (jsonDecode(body) as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<void> updateWeather(Map<String, dynamic> partial) async {
    final url = Uri.parse('$_baseDbUrl/weather.json?auth=$_idToken');
    final resp = await _client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(partial),
    );
    if (resp.statusCode >= 400) {
      throw Exception('PATCH weather failed: ${resp.statusCode} ${resp.body}');
    }
  }

  
  String sseUrl() => '$_baseDbUrl/weather.json?auth=$_idToken';

  String? get uid => _uid;
}

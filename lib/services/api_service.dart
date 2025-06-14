
class ApiService {
  // TODO: Env variables
  static const String _baseUrl = 'http://localhost:8080';

  static const Duration _timeout = Duration(seconds: 10);

  // TODO: Env variables
  static const String _authToken = 'TODO: ABSTRACT AUTHENTICATION';

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  String get baseUrl => _baseUrl;

  Duration get timeout => _timeout;

  Map<String, String> get headers => _headers;
}

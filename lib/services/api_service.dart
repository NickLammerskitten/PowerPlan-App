import 'auth/supabase_service.dart';

class ApiService {
  // TODO: Env variables
  static const String _baseUrl = 'http://localhost:8080';

  static const Duration _timeout = Duration(seconds: 15);

  Map<String, String> get _headers {
    final token = SupabaseService.client.auth.currentSession?.accessToken;

    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  String get baseUrl => _baseUrl;

  Duration get timeout => _timeout;

  Map<String, String> get headers => _headers;
}

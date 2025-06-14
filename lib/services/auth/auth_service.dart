import 'package:flutter/foundation.dart';
import 'package:power_plan_fe/services/auth/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  error
}

class AuthService extends ChangeNotifier {
  String? _errorMessage;
  bool _isAuthenticated = false;
  AuthStatus _status = AuthStatus.initial;

  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  AuthStatus get status => _status;

  User? get currentUser => SupabaseService.client.auth.currentUser;

  Future<void> initialize() async {
    await _checkAuth();

    SupabaseService.authStateChanges.listen((state) {
      _isAuthenticated = state.session != null;
      _status = _isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = SupabaseService.isAuthenticated;
    _status = _isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      _errorMessage = null;
      _isAuthenticated = true;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _handleAuthError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
      );

      _errorMessage = null;
      _isAuthenticated = response.session != null;
      _status = _isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _handleAuthError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await SupabaseService.signOut();
      _isAuthenticated = false;
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Fehler beim Abmelden: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await SupabaseService.resetPassword(email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _handleAuthError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Benutzer ist nicht angemeldet';
        notifyListeners();
        return false;
      }

      final email = user.email;
      if (email == null) {
        _errorMessage = 'Benutzer-E-Mail konnte nicht ermittelt werden';
        notifyListeners();
        return false;
      }

      try {
        await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: currentPassword,
        );
      } catch (e) {
        _errorMessage = 'Aktuelles Passwort ist nicht korrekt';
        notifyListeners();
        return false;
      }

      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void _handleAuthError(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        _errorMessage = 'Ungültige Anmeldedaten. Bitte überprüfen Sie Ihre E-Mail und Ihr Passwort.';
      case 'Email not confirmed':
        _errorMessage = 'Bitte bestätigen Sie Ihre E-Mail-Adresse, bevor Sie sich anmelden.';
      case 'User already registered':
        _errorMessage = 'Diese E-Mail-Adresse ist bereits registriert.';
      case 'Password should be at least 6 characters':
        _errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.';
      default:
        _errorMessage = 'Authentifizierungsfehler: ${e.message}';
    }
    notifyListeners();
  }
}

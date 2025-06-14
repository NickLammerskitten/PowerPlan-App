import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateCurrentPassword);
    _newPasswordController.addListener(() {
      _validateNewPassword();
      _validateConfirmPassword();
    });
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_validateCurrentPassword);
    _newPasswordController.removeListener(_validateNewPassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateCurrentPassword() {
    final currentPassword = _currentPasswordController.text;
    setState(() {
      if (currentPassword.isEmpty) {
        _currentPasswordError = 'Aktuelles Passwort ist erforderlich';
      } else if (currentPassword.length < 6) {
        _currentPasswordError = 'Passwort muss mindestens 6 Zeichen lang sein';
      } else {
        _currentPasswordError = null;
      }
    });
  }

  void _validateNewPassword() {
    final newPassword = _newPasswordController.text;
    setState(() {
      if (newPassword.isEmpty) {
        _newPasswordError = 'Neues Passwort ist erforderlich';
      } else if (newPassword.length < 6) {
        _newPasswordError = 'Passwort muss mindestens 6 Zeichen lang sein';
      } else if (newPassword == _currentPasswordController.text) {
        _newPasswordError = 'Neues Passwort muss sich vom aktuellen unterscheiden';
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Passwortbestätigung ist erforderlich';
      } else if (newPassword != confirmPassword) {
        _confirmPasswordError = 'Passwörter stimmen nicht überein';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _areInputsValid() {
    _validateCurrentPassword();
    _validateNewPassword();
    _validateConfirmPassword();

    return _currentPasswordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _changePassword() async {
    // Validierung vor dem Absenden
    if (!_areInputsValid()) {
      setState(() {
        _errorMessage = 'Bitte korrigieren Sie die Fehler in den Eingabefeldern';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await Provider.of<AuthService>(context, listen: false)
          .changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        setState(() {
          _successMessage = 'Passwort wurde erfolgreich geändert';
          // Felder zurücksetzen
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = Provider.of<AuthService>(context, listen: false).errorMessage ??
              'Fehler beim Ändern des Passworts';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Passwort ändern'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 24),

            // Fehlermeldung
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Erfolgsmeldung
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: CupertinoColors.activeGreen),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Passwortänderungsformular
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aktuelles Passwort', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _currentPasswordController,
                    placeholder: 'Aktuelles Passwort eingeben',
                    obscureText: true,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _currentPasswordError != null
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey4
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_currentPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _currentPasswordError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  const Text('Neues Passwort', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _newPasswordController,
                    placeholder: 'Neues Passwort eingeben',
                    obscureText: true,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _newPasswordError != null
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey4
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_newPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _newPasswordError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Passwort-Anforderungen
                  const Text(
                    'Passwort muss mindestens 6 Zeichen lang sein',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Neues Passwort bestätigen', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _confirmPasswordController,
                    placeholder: 'Neues Passwort wiederholen',
                    obscureText: true,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _confirmPasswordError != null
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey4
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _confirmPasswordError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                  // Passwort ändern Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: _isLoading ? null : _changePassword,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text('Passwort ändern', style: TextStyle(color: CupertinoColors.white)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Abbrechen Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey6,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text(
                        'Abbrechen',
                        style: TextStyle(color: CupertinoColors.activeBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
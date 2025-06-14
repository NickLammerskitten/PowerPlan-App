
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(() {
      _validatePassword();
      _validateConfirmPassword();
    });
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return email.isNotEmpty && emailRegExp.hasMatch(email);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'E-Mail ist erforderlich';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Bitte geben Sie eine gültige E-Mail-Adresse ein';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'Passwort ist erforderlich';
      } else if (password.length < 6) {
        _passwordError = 'Passwort muss mindestens 6 Zeichen lang sein';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Passwortbestätigung ist erforderlich';
      } else if (password != confirmPassword) {
        _confirmPasswordError = 'Passwörter stimmen nicht überein';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _areInputsValid() {
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _register() async {
    if (!_areInputsValid()) {
      setState(() {
        _errorMessage = 'Bitte korrigieren Sie die Fehler in den Eingabefeldern';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await Provider.of<AuthService>(context, listen: false)
        .signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() {
        _errorMessage = Provider.of<AuthService>(context, listen: false).errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Registrieren'),
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

            // Registrierungsformular
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('E-Mail', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'E-Mail-Adresse eingeben',
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _emailError != null
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey4
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  const Text('Passwort', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: 'Passwort eingeben',
                    obscureText: true,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _passwordError != null
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey4
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Passwort-Anforderungen
                  Text(
                    'Passwort muss mindestens 6 Zeichen lang sein',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Passwort bestätigen', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _confirmPasswordController,
                    placeholder: 'Passwort wiederholen',
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

                  const SizedBox(height: 24),
                  // Registrieren-Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: _isLoading ? null : _register,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text('Registrieren', style: TextStyle(color: CupertinoColors.white)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Zurück zur Anmeldung
                  Center(
                    child: CupertinoButton(
                      child: const Text('Bereits registriert? Anmelden'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
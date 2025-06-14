
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:power_plan_fe/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _emailController.dispose();
    _passwordController.dispose();
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

  bool _areInputsValid() {
    _validateEmail();
    _validatePassword();
    return _emailError == null && _passwordError == null;
  }

  Future<void> _login() async {
    // Validierung vor dem Absenden
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
        .signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      setState(() {
        _errorMessage = Provider.of<AuthService>(context, listen: false).errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Anmelden'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 40),
            // Logo oder App-Name
            const Center(
              child: Icon(
                CupertinoIcons.headphones,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Powerplan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

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

            // Anmeldeformular
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

                  const SizedBox(height: 24),
                  // Anmelde-Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: _isLoading ? null : _login,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text('Anmelden', style: TextStyle(color: CupertinoColors.white)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Passwort vergessen
                  Center(
                    child: CupertinoButton(
                      child: const Text('Passwort vergessen?'),
                      onPressed: () {
                        // TODO: Navigieren Sie zur Passwort-Reset-Seite
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Trennlinie
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Noch kein Konto?'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Registrieren-Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey6,
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text(
                        'Registrieren',
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
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:power_plan_fe/theme/app_colors.dart';
import 'package:power_plan_fe/theme/app_radius.dart';
import 'package:power_plan_fe/theme/app_spacing.dart';
import 'package:power_plan_fe/theme/app_text_styles.dart';
import 'package:power_plan_fe/widgets/app_error_view.dart';
import 'package:power_plan_fe/widgets/app_primary_button.dart';
import 'package:power_plan_fe/widgets/app_secondary_button.dart';
import 'package:power_plan_fe/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        _emailError = 'Bitte gib eine gültige E-Mail-Adresse ein';
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
        _errorMessage = 'Bitte korrigiere die Fehler in den Eingabefeldern';
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

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() {
        _errorMessage =
            Provider.of<AuthService>(context, listen: false).errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: Text('Registrieren'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.person_add_solid,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text('Konto erstellen', style: AppTextStyles.titleLg),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'Starte deine Powerplan-Reise.',
                style: AppTextStyles.bodySecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            if (_errorMessage != null) ...[
              AppErrorView(message: _errorMessage!, compact: true),
              const SizedBox(height: AppSpacing.lg),
            ],

            AppTextField(
              controller: _emailController,
              label: 'E-Mail',
              placeholder: 'E-Mail-Adresse eingeben',
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              autocorrect: false,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: 'Passwort',
              placeholder: 'Passwort eingeben',
              obscureText: true,
              errorText: _passwordError,
              helperText: 'Mindestens 6 Zeichen.',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Passwort bestätigen',
              placeholder: 'Passwort wiederholen',
              obscureText: true,
              errorText: _confirmPasswordError,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Registrieren',
              icon: CupertinoIcons.person_add,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _register,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(
              label: 'Bereits registriert? Anmelden',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

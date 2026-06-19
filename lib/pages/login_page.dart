import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:power_plan_fe/pages/register_page.dart';
import 'package:power_plan_fe/theme/app_colors.dart';
import 'package:power_plan_fe/theme/app_radius.dart';
import 'package:power_plan_fe/theme/app_spacing.dart';
import 'package:power_plan_fe/theme/app_text_styles.dart';
import 'package:power_plan_fe/widgets/app_error_view.dart';
import 'package:power_plan_fe/widgets/app_primary_button.dart';
import 'package:power_plan_fe/widgets/app_secondary_button.dart';
import 'package:power_plan_fe/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  bool _areInputsValid() {
    _validateEmail();
    _validatePassword();
    return _emailError == null && _passwordError == null;
  }

  Future<void> _login() async {
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
        .signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
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
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  size: 52,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text('Powerplan', style: AppTextStyles.titleLg),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'Dein moderner Trainingsbegleiter.',
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

            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Anmelden',
              icon: CupertinoIcons.arrow_right_circle_fill,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _login,
            ),

            const SizedBox(height: AppSpacing.lg),
            const _DividerWithLabel(label: 'Noch kein Konto?'),
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(
              label: 'Registrieren',
              icon: CupertinoIcons.person_add,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

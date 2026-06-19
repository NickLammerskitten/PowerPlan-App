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

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
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
        _newPasswordError =
            'Neues Passwort muss sich vom aktuellen unterscheiden';
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
    if (!_areInputsValid()) {
      setState(() {
        _errorMessage = 'Bitte korrigiere die Fehler in den Eingabefeldern';
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

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        setState(() {
          _successMessage = 'Passwort wurde erfolgreich geändert';
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else if (mounted) {
        setState(() {
          _errorMessage =
              Provider.of<AuthService>(context, listen: false).errorMessage ??
                  'Fehler beim Ändern des Passworts';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: Text('Passwort ändern'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.lg),
            if (_errorMessage != null) ...[
              AppErrorView(message: _errorMessage!, compact: true),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_successMessage != null) ...[
              _SuccessBanner(message: _successMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              controller: _currentPasswordController,
              label: 'Aktuelles Passwort',
              placeholder: 'Aktuelles Passwort eingeben',
              obscureText: true,
              errorText: _currentPasswordError,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _newPasswordController,
              label: 'Neues Passwort',
              placeholder: 'Neues Passwort eingeben',
              obscureText: true,
              errorText: _newPasswordError,
              helperText: 'Mindestens 6 Zeichen.',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Neues Passwort bestätigen',
              placeholder: 'Neues Passwort wiederholen',
              obscureText: true,
              errorText: _confirmPasswordError,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Passwort ändern',
              icon: CupertinoIcons.lock_rotation,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _changePassword,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSecondaryButton(
              label: 'Abbrechen',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

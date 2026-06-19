import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Primärer CTA-Button in Akzentfarbe (oder Danger-Variante).
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bgColor = danger ? AppColors.danger : AppColors.accent;
    final enabled = onPressed != null && !isLoading;

    final content = isLoading
        ? const CupertinoActivityIndicator(color: AppColors.onAccent)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.onAccent),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTextStyles.buttonLg),
            ],
          );

    final button = CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      color: bgColor,
      disabledColor: bgColor.withValues(alpha: 0.4),
      borderRadius: AppRadius.mdAll,
      onPressed: enabled ? onPressed : null,
      child: content,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

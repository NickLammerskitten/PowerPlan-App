import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// `CupertinoTextField` mit konsistentem Dark-Look, Label, Helper- und Error-Text.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.trailing,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.autocorrect = true,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? trailing;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? AppColors.danger : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs + 2),
        ],
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          cursorColor: AppColors.accent,
          style: AppTextStyles.body,
          placeholderStyle: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.md + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: borderColor, width: 1),
          ),
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Icon(
                    prefixIcon,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          suffix: trailing,
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.danger),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(helperText!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

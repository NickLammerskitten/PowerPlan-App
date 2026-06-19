import 'package:flutter/cupertino.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Factory für das zentrale Cupertino-Theme der App.
abstract class AppTheme {
  static CupertinoThemeData cupertino() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.accent,
      primaryContrastingColor: AppColors.onAccent,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.surface,
      applyThemeToAll: true,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.accent,
        textStyle: AppTextStyles.body,
        actionTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        navActionTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        pickerTextStyle: TextStyle(
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Mehrstufiger Fortschrittsindikator (Akzent für aktive/abgeschlossene Schritte).
class AppStepIndicator extends StatelessWidget {
  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  /// 0-basierter Index des aktiven Schritts.
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final segments = <Widget>[];
    for (var i = 0; i < totalSteps; i++) {
      final isActive = i <= currentStep;
      segments.add(
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : AppColors.surfaceElevated,
              borderRadius: AppRadius.pillAll,
            ),
          ),
        ),
      );
      if (i < totalSteps - 1) {
        segments.add(const SizedBox(width: AppSpacing.xs));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: segments),
        const SizedBox(height: AppSpacing.sm),
        Text(
          labels != null && currentStep < labels!.length
              ? 'Schritt ${currentStep + 1} von $totalSteps · ${labels![currentStep]}'
              : 'Schritt ${currentStep + 1} von $totalSteps',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

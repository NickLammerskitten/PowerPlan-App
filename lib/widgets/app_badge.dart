import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Farbige Chip-/Badge-Komponente.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  /// Erzeugt einen Badge, der den (Roh-)Schwierigkeitsgrad eines Plans
  /// auf semantische Farben abbildet.
  factory AppBadge.difficulty(String? level, {Key? key}) {
    final mapped = _difficultyFor(level);
    return AppBadge(
      key: key,
      label: mapped.label,
      color: mapped.fg,
      backgroundColor: mapped.bg,
    );
  }

  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.18);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static _DifficultyTokens _difficultyFor(String? level) {
    switch (level?.toUpperCase()) {
      case 'BEGINNER':
        return const _DifficultyTokens(
          'Beginner',
          AppColors.success,
          AppColors.successSoft,
        );
      case 'INTERMEDIATE':
        return const _DifficultyTokens(
          'Intermediate',
          AppColors.warning,
          AppColors.warningSoft,
        );
      case 'ADVANCED':
        return const _DifficultyTokens(
          'Advanced',
          AppColors.accent,
          AppColors.accentSoft,
        );
      case 'EXPERT':
        return const _DifficultyTokens(
          'Expert',
          AppColors.danger,
          AppColors.dangerSoft,
        );
      default:
        return _DifficultyTokens(
          'Unbekannt',
          AppColors.textSecondary,
          AppColors.surfaceElevated,
        );
    }
  }
}

class _DifficultyTokens {
  const _DifficultyTokens(this.label, this.fg, this.bg);
  final String label;
  final Color fg;
  final Color bg;
}

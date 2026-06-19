import 'package:flutter/cupertino.dart';

import 'model/plan_list_item.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/app_badge.dart';
import 'widgets/app_card.dart';

class PlanRowItem extends StatelessWidget {
  const PlanRowItem({super.key, required this.plan, this.onTap});

  final PlanListItem plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = plan.classifications.isNotEmpty
        ? plan.classifications.join(' · ')
        : null;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: AppTextStyles.titleSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                AppBadge.difficulty(plan.difficultyLevel),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

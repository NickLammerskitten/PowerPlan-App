import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/create_plan/create_plan_page.dart';
import 'package:power_plan_fe/pages/plan_list_page.dart';

import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/app_card.dart';
import 'widgets/app_primary_button.dart';
import 'widgets/app_secondary_button.dart';
import 'widgets/app_section_header.dart';

class TrainingTab extends StatelessWidget {
  const TrainingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CupertinoSliverNavigationBar(
          backgroundColor: AppColors.background,
          largeTitle: Text('Training'),
        ),
        SliverSafeArea(
          top: false,
          minimum: const EdgeInsets.only(top: AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bereit zum Training?', style: AppTextStyles.displayLg),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Plane, verfolge und meistere deine Workouts.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(
                    title: 'Plan Manager',
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Erstelle einen neuen Trainingsplan oder durchsuche alle gespeicherten Pläne.',
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(
                          label: 'Plan erstellen',
                          icon: CupertinoIcons.add,
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => CreatePlanPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSecondaryButton(
                          label: 'Alle Trainingspläne',
                          icon: CupertinoIcons.list_bullet,
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => const PlanListPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/model/app_state_model.dart';
import 'package:power_plan_fe/pages/edit_plan/plan_edit_page.dart';
import 'package:power_plan_fe/plan_row_item.dart';
import 'package:power_plan_fe/theme/app_colors.dart';
import 'package:power_plan_fe/theme/app_spacing.dart';
import 'package:power_plan_fe/widgets/app_empty_state.dart';
import 'package:power_plan_fe/widgets/app_error_view.dart';
import 'package:power_plan_fe/widgets/app_icon_button.dart';
import 'package:power_plan_fe/widgets/app_loading_view.dart';
import 'package:provider/provider.dart';

class PlanListPage extends StatelessWidget {
  const PlanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          final plans = model.getPlans();

          Widget body;
          if (model.isLoading) {
            body = const SliverFillRemaining(
              hasScrollBody: false,
              child: AppLoadingView(message: 'Lade Trainingspläne…'),
            );
          } else if (model.error != null) {
            body = SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorView(
                title: 'Fehler beim Laden',
                message: model.error!,
                onRetry: () => model.loadPlans(),
              ),
            );
          } else if (plans.isEmpty) {
            body = const SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: CupertinoIcons.square_list,
                title: 'Noch keine Trainingspläne',
                subtitle:
                    'Lege deinen ersten Plan an, um mit dem Training durchzustarten.',
              ),
            );
          } else {
            body = SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: PlanRowItem(
                        plan: plans[index],
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  PlanEditPage(id: plans[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: plans.length,
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                backgroundColor: AppColors.background,
                largeTitle: const Text('Trainingspläne'),
                trailing: AppIconButton(
                  icon: CupertinoIcons.refresh,
                  accent: true,
                  size: 36,
                  iconSize: 18,
                  onPressed: () => model.loadPlans(),
                ),
              ),
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: AppSpacing.sm),
                sliver: body,
              ),
            ],
          );
        },
      ),
    );
  }
}

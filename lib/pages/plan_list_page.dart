import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/model/app_state_model.dart';
import 'package:power_plan_fe/pages/edit_plan/plan_edit_page.dart';
import 'package:power_plan_fe/plan_row_item.dart';
import 'package:provider/provider.dart';

class PlanListPage extends StatelessWidget {
  const PlanListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          final plans = model.getPlans();

          return CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Trainingspläne'),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.refresh),
                  onPressed: () {
                    model.loadPlans();
                  },
                ),
              ),
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 8),
                sliver: model.isLoading
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      )
                    : model.error != null
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Text(
                                  'Fehler beim Laden',
                                  style: CupertinoTheme.of(
                                    context,
                                  ).textTheme.navTitleTextStyle,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  model.error!,
                                  style: TextStyle(
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : plans.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Keine Trainingspläne vorhanden',
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.textStyle,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => PlanEditPage(
                                    id: plans[index].id
                                  ),
                                ),
                              );
                            },
                            child: PlanRowItem(plan: plans[index]),
                          );
                        }, childCount: plans.length),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

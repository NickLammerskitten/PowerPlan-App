import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/create_plan/create_plan_page.dart';
import 'package:power_plan_fe/pages/plan_list_page.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';

class TrainingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(largeTitle: const Text('Training')),
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan Manager',
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.navTitleTextStyle,
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Alle Trainingspläne',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => PlanListPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.add, size: 20),
                              SizedBox(width: 8),
                              Text('Plan Erstellen'),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => CreatePlanPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

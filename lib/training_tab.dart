import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'plan_row_item.dart';

class TrainingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          final plans = model.getPlans();

          return CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Training'),
              ),
              SliverSafeArea(
                // BEGINNING OF NEW CONTENT
                top: false,
                minimum: const EdgeInsets.only(top: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < plans.length) {
                      return PlanRowItem(plan: plans[index]);
                    }
                    return null;
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

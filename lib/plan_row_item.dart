import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/styles.dart';

import 'model/plan_list_item.dart';

class PlanRowItem extends StatelessWidget {
  const PlanRowItem({required this.plan});

  final PlanListItem plan;

  @override
  Widget build(BuildContext context) {
    final row = SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    plan.name,
                    style: Styles.productRowItemName,
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  Text(
                    '${plan.difficultyLevel?.toLowerCase()}',
                    style: Styles.productRowItemPrice,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: <Widget>[
        row,
        Padding(
          padding: const EdgeInsets.only(
            left: 100,
            right: 16,
          ),
          child: Container(
            height: 1,
            color: Styles.productRowDivider,
          ),
        ),
      ],
    );
  }
}

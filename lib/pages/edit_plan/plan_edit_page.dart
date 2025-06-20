import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/services/api/plan_api.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanEditPage extends StatefulWidget {
  const PlanEditPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _PlanEditPageState createState() => _PlanEditPageState();
}

class _PlanEditPageState extends State<PlanEditPage> {
  final PlanApi _planApi = PlanApi(ApiService());
  late Future<Plan> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = _planApi.fetchPlan(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Plan Bearbeiten'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Speichern'),
          onPressed: () {
            // Save changes will be implemented later
            Navigator.of(context).pop();
          },
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<Plan>(
          future: _planFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found'));
            }

            final plan = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Plan name display
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name des Plans:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Placeholder for future content
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Plan-Bearbeitungsfunktionen werden hier angezeigt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

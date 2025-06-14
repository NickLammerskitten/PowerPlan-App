import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:power_plan_fe/services/auth/supabase_service.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'model/app_state_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) {
            final authModel = AuthService();

            authModel.initialize();
            return authModel;
          },
        ),
        ChangeNotifierProxyProvider<AuthService, AppStateModel>(
          create: (context) => AppStateModel(),
          update: (context, authModel, appStateModel) {
            if (authModel.isAuthenticated && appStateModel != null) {
              appStateModel.loadPlans();
            }
            return appStateModel!;
          },
        ),
      ],
      child: PowerplanApp(),
    ),
  );

}

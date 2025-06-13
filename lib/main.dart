import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import 'app.dart';
import 'model/app_state_model.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (context) => AppStateModel()..loadPlans(),
      child: PowerplanApp(),
    ),
  );
}

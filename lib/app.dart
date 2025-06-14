import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/login_page.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/training_tab.dart';
import 'package:power_plan_fe/settings_tab.dart';

class PowerplanApp extends StatelessWidget {
  const PowerplanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthService>(context);

    switch (authModel.status) {
      case AuthStatus.initial:
        return const CupertinoPageScaffold(
          child: Center(child: CupertinoActivityIndicator()),
        );

      case AuthStatus.authenticated:
        return PowerplanHomePage();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      return const LoginPage();
    }
  }
}

class PowerplanHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.headphones),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: TrainingTab(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SettingsTab(),
              );
            });
          default:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(child: Text('Tab not found')),
              );
            });
        }
      },
    );
  }
}
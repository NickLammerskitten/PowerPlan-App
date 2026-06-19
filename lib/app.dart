import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/login_page.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:power_plan_fe/training_tab.dart';
import 'package:power_plan_fe/settings_tab.dart';
import 'package:power_plan_fe/theme/app_colors.dart';
import 'package:power_plan_fe/theme/app_theme.dart';
import 'package:power_plan_fe/widgets/app_loading_view.dart';

class PowerplanApp extends StatelessWidget {
  const PowerplanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Powerplan',
      theme: AppTheme.cupertino(),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthService>(context);

    switch (authModel.status) {
      case AuthStatus.initial:
        return const CupertinoPageScaffold(
          backgroundColor: AppColors.background,
          child: AppLoadingView(),
        );

      case AuthStatus.authenticated:
        return const PowerplanHomePage();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginPage();
    }
  }
}

class PowerplanHomePage extends StatelessWidget {
  const PowerplanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        activeColor: AppColors.accent,
        inactiveColor: AppColors.textSecondary,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bolt_fill),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            label: 'Einstellungen',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(
                backgroundColor: AppColors.background,
                child: TrainingTab(),
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(
                backgroundColor: AppColors.background,
                child: SettingsTab(),
              ),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(
                backgroundColor: AppColors.background,
                child: Center(child: Text('Tab not found')),
              ),
            );
        }
      },
    );
  }
}
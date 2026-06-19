import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/change_password_page.dart';
import 'package:power_plan_fe/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'theme/app_colors.dart';
import 'theme/app_radius.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/app_card.dart';
import 'widgets/app_primary_button.dart';
import 'widgets/app_section_header.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return CustomScrollView(
      slivers: <Widget>[
        const CupertinoSliverNavigationBar(
          backgroundColor: AppColors.background,
          largeTitle: Text('Einstellungen'),
        ),
        SliverSafeArea(
          top: false,
          minimum: const EdgeInsets.only(top: AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Profil',
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                  ),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: AppRadius.lgAll,
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.person_fill,
                            color: AppColors.accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.email ?? 'Nicht verfügbar',
                                style: AppTextStyles.titleSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Mitglied seit ${_formatDate(currentUser?.createdAt)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(
                    title: 'Konto',
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                  ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.lock_fill,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Passwort ändern',
                              style: AppTextStyles.body,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  AppPrimaryButton(
                    label: 'Abmelden',
                    icon: CupertinoIcons.square_arrow_right,
                    danger: true,
                    onPressed: () async {
                      await authService.signOut();
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      'Powerplan v1.0.0',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      '© 2025 Powerplan',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Nicht verfügbar';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    } catch (e) {
      return 'Unbekannt';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  static const String routeName = AppRoutes.home;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: AppGlass(
            isStrong: true,
            borderRadius: BorderRadius.zero,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutterCompact,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: AppTypography.title.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            AppStrings.homePlaceholderTitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      onPressed: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(
                DateTime.now(),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.gutterCompact),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.primarySoft,
                                    child: Text(
                                      (user?.name.isNotEmpty ?? false)
                                          ? user!.name[0].toUpperCase()
                                          : 'K',
                                      style: AppTypography.headlineMd.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.name ?? 'Kasir Vonte',
                                          style:
                                              AppTypography.title.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '@${user?.username ?? "kasir"}',
                                          style: AppTypography.bodySm.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successSoft,
                                      borderRadius: AppRadius.borderRadiusFull,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          AppStrings.activeSessionTitle,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              const Divider(
                                color: AppColors.borderHairline,
                                height: 1,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Waktu Sesi Dimulai',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    dateFormatted,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures:
                                          AppTypography.tabularFigures,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ID Pengguna',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '#${user?.id ?? 0}',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures:
                                          AppTypography.tabularFigures,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          text: AppStrings.logout,
                          variant: AppButtonVariant.destructive,
                          leadingIcon: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: AppColors.error,
                          ),
                          onPressed: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXl,
          ),
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            'Konfirmasi Keluar',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin mengakhiri sesi kasir ini?',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            AppButton(
              text: AppStrings.logout,
              variant: AppButtonVariant.destructive,
              isSolidDestructive: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../addon/presentation/cubit/addon_cubit.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../domain/entities/store_profile.dart';
import '../../domain/validators/store_profile_validator.dart';
import '../cubit/store_profile_cubit.dart';
import '../cubit/store_profile_state.dart';

class SettingsPage extends StatefulWidget {
  final StoreProfileCubit? storeProfileCubit;

  const SettingsPage({super.key, this.storeProfileCubit});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.storeProfileCubit != null) {
      return BlocProvider<StoreProfileCubit>.value(
        value: widget.storeProfileCubit!..loadProfile(),
        child: const _SettingsView(),
      );
    }

    if (getIt.isRegistered<StoreProfileCubit>()) {
      return BlocProvider<StoreProfileCubit>(
        create: (_) => getIt<StoreProfileCubit>()..loadProfile(),
        child: const _SettingsView(),
      );
    }

    return const _SettingsView();
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _receiptFooterController = TextEditingController();

  String? _nameError;
  String? _addressError;
  String? _phoneError;
  String? _receiptFooterError;

  bool _initializedFromState = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  void _syncControllers(StoreProfile profile) {
    _nameController.text = profile.name;
    _addressController.text = profile.address;
    _phoneController.text = profile.phone;
    _receiptFooterController.text = profile.receiptFooter;
    _initializedFromState = true;
  }

  void _onSave(BuildContext context) {
    setState(() {
      _nameError = StoreProfileValidator.validateName(_nameController.text);
      _addressError =
          StoreProfileValidator.validateAddress(_addressController.text);
      _phoneError = StoreProfileValidator.validatePhone(_phoneController.text);
      _receiptFooterError = StoreProfileValidator.validateReceiptFooter(
        _receiptFooterController.text,
      );
    });

    if (_nameError == null &&
        _addressError == null &&
        _phoneError == null &&
        _receiptFooterError == null) {
      try {
        context.read<StoreProfileCubit>().updateProfile(
              name: _nameController.text,
              address: _addressController.text,
              phone: _phoneController.text,
              receiptFooter: _receiptFooterController.text,
            );
      } catch (_) {}
    }
  }

  void _confirmSeedData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXl,
          ),
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            AppStrings.seedSampleDataConfirmTitle,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            AppStrings.seedSampleDataConfirmMessage,
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
              text: AppStrings.confirmSeed,
              variant: AppButtonVariant.primary,
              onPressed: () {
                ProductCubit? productCubit;
                CategoryCubit? categoryCubit;
                AddonCubit? addonCubit;
                try {
                  productCubit = context.read<ProductCubit>();
                } catch (_) {}
                try {
                  categoryCubit = context.read<CategoryCubit>();
                } catch (_) {}
                try {
                  addonCubit = context.read<AddonCubit>();
                } catch (_) {}

                Navigator.of(dialogContext).pop();
                try {
                  context.read<StoreProfileCubit>().seedData().then((seeded) {
                    if (seeded) {
                      productCubit?.loadProducts();
                      categoryCubit?.loadCategories();
                      addonCubit?.loadAddons();
                    }
                  });
                } catch (_) {}
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXl,
          ),
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            AppStrings.logoutConfirmTitle,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            AppStrings.logoutConfirmMessage,
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

  @override
  Widget build(BuildContext context) {
    StoreProfileCubit? cubit;
    try {
      cubit = context.read<StoreProfileCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit != null) {
      return BlocConsumer<StoreProfileCubit, StoreProfileState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.userMessage != current.userMessage ||
            (!_initializedFromState && current.profile != null),
        listener: (context, state) {
          if (state.profile != null && !_initializedFromState) {
            _syncControllers(state.profile!);
          }

          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<StoreProfileCubit>().clearMessages();
          } else if (state.userMessage != null &&
              state.userMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.userMessage!),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<StoreProfileCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.profile != null && !_initializedFromState) {
            _syncControllers(state.profile!);
          }
          return _buildScaffold(context, state: state);
        },
      );
    }

    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context, {StoreProfileState? state}) {
    final isLoading = state?.status == StoreProfileStatus.loading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.navBarHeight),
        child: AppGlass(
          isStrong: true,
          borderRadius: BorderRadius.zero,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: AppSizes.navBarHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutterCompact,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
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
                          AppStrings.navSettings,
                          style: AppTypography.title.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          AppStrings.settingsPlaceholderSubtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutterCompact),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserSessionCard(),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.lg),
                  _buildStoreProfileCard(context, isLoading: isLoading),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSampleDataCard(context, isLoading: isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSessionCard() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(
          DateTime.now(),
        );

        return AppCard(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Kasir Vonte',
                          style: AppTypography.title.copyWith(
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
                    decoration: const BoxDecoration(
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
              const Divider(color: AppColors.borderHairline, height: 1),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.userSessionStartTime,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    dateFormatted,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.userIdLabel,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '#${user?.id ?? 0}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreProfileCard(BuildContext context, {required bool isLoading}) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.storeProfileTitle,
                      style: AppTypography.title.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.storeProfileSubtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.borderHairline, height: 1),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const Key('store_name_field'),
            label: AppStrings.storeNameLabel,
            hint: AppStrings.storeNameHint,
            controller: _nameController,
            errorText: _nameError,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              if (_nameError != null) {
                setState(() {
                  _nameError = StoreProfileValidator.validateName(val);
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('store_address_field'),
            label: AppStrings.storeAddressLabel,
            hint: AppStrings.storeAddressHint,
            controller: _addressController,
            errorText: _addressError,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              if (_addressError != null) {
                setState(() {
                  _addressError = StoreProfileValidator.validateAddress(val);
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('store_phone_field'),
            label: AppStrings.storePhoneLabel,
            hint: AppStrings.storePhoneHint,
            controller: _phoneController,
            errorText: _phoneError,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              if (_phoneError != null) {
                setState(() {
                  _phoneError = StoreProfileValidator.validatePhone(val);
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('store_footer_field'),
            label: AppStrings.storeReceiptFooterLabel,
            hint: AppStrings.storeReceiptFooterHint,
            controller: _receiptFooterController,
            errorText: _receiptFooterError,
            textInputAction: TextInputAction.done,
            onChanged: (val) {
              if (_receiptFooterError != null) {
                setState(() {
                  _receiptFooterError =
                      StoreProfileValidator.validateReceiptFooter(val);
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('save_store_profile_button'),
            text: AppStrings.saveStoreProfile,
            variant: AppButtonVariant.primary,
            fullWidth: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _onSave(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleDataCard(BuildContext context, {required bool isLoading}) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.dataset_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sampleDataTitle,
                      style: AppTypography.title.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.sampleDataSubtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.borderHairline, height: 1),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const Key('seed_sample_data_button'),
            text: AppStrings.seedSampleData,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            isLoading: isLoading,
            leadingIcon: const Icon(
              Icons.download_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: isLoading ? null : () => _confirmSeedData(context),
          ),
        ],
      ),
    );
  }
}


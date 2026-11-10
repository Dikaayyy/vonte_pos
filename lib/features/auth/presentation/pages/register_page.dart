import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../domain/validators/auth_validator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = AppRoutes.register;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final name = _nameController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    final nError = AuthValidator.validateName(name);
    final uError = AuthValidator.validateUsername(username);
    final pError = AuthValidator.validatePassword(password);

    setState(() {
      _nameError = nError;
      _usernameError = uError;
      _passwordError = pError;
    });

    if (nError == null && uError == null && pError == null) {
      context.read<AuthCubit>().register(
            name: name.trim(),
            username: username.trim(),
            password: password,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient wash: at most 2 soft circles per DESIGN.md
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.atmosTeal.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.atmosSky.withValues(alpha: 0.25),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutterCompact,
                    vertical: AppSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.status == AuthStatus.loading;

                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Icon
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: AppRadius.borderRadiusMd,
                                  ),
                                  child: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                AppStrings.authRegisterTitle,
                                style: AppTypography.headlineMd.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppStrings.authRegisterSubtitle,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Server / Business Rule Error
                              if (state.status == AuthStatus.failure &&
                                  state.errorMessage != null) ...[
                                InlineError(message: state.errorMessage!),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // Full Name Input
                              AppTextField(
                                label: AppStrings.nameLabel,
                                hint: AppStrings.nameHint,
                                controller: _nameController,
                                errorText: _nameError,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onChanged: (value) {
                                  if (_nameError != null) {
                                    setState(() {
                                      _nameError =
                                          AuthValidator.validateName(value);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Username Input
                              AppTextField(
                                label: AppStrings.usernameLabel,
                                hint: AppStrings.usernameHint,
                                controller: _usernameController,
                                errorText: _usernameError,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onChanged: (value) {
                                  if (_usernameError != null) {
                                    setState(() {
                                      _usernameError =
                                          AuthValidator.validateUsername(value);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password Input
                              AppTextField(
                                label: AppStrings.passwordLabel,
                                hint: AppStrings.passwordHint,
                                controller: _passwordController,
                                isPassword: true,
                                errorText: _passwordError,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onSubmitted: (_) => _validateAndSubmit(),
                                onChanged: (value) {
                                  if (_passwordError != null) {
                                    setState(() {
                                      _passwordError =
                                          AuthValidator.validatePassword(value);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Action Button "Daftar"
                              AppButton(
                                text: AppStrings.registerButton,
                                variant: AppButtonVariant.primary,
                                isLarge: true,
                                isLoading: isLoading,
                                onPressed:
                                    isLoading ? null : _validateAndSubmit,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Switch to Login
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.haveAccount,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context
                                                .read<AuthCubit>()
                                                .clearError();
                                            Navigator.pop(context);
                                          },
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(48, 48),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.goToLogin,
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

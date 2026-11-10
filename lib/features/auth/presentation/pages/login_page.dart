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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = AppRoutes.login;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final uError = AuthValidator.validateUsername(username);
    final pError = AuthValidator.validatePassword(password);

    setState(() {
      _usernameError = uError;
      _passwordError = pError;
    });

    if (uError == null && pError == null) {
      context.read<AuthCubit>().login(
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
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                              // App Identity Icon
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
                                    Icons.point_of_sale_rounded,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                AppStrings.authLoginTitle,
                                style: AppTypography.headlineMd.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppStrings.authLoginSubtitle,
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

                              // Action Button "Masuk"
                              AppButton(
                                text: AppStrings.loginButton,
                                variant: AppButtonVariant.primary,
                                isLarge: true,
                                isLoading: isLoading,
                                onPressed:
                                    isLoading ? null : _validateAndSubmit,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Switch to Register
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.dontHaveAccount,
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
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.register,
                                            );
                                          },
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(48, 48),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.goToRegister,
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

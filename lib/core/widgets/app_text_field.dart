import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Text field styled strictly according to DESIGN.md:
/// - Crisp white or glass background
/// - Hairline border with 2px primary focus ring
/// - Label displayed prominently above input
/// - Min 48dp tap target
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: widget.isPassword ? _obscured : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      splashRadius: 24,
                      onPressed: () {
                        setState(() {
                          _obscured = !_obscured;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: const BorderSide(
                  color: AppColors.borderHairline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.borderHairline,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: const BorderSide(
                  color: AppColors.borderHairline,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceCard,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}


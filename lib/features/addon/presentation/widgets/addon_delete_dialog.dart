import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/addon.dart';

class AddonDeleteDialog extends StatefulWidget {
  final Addon addon;
  final Future<void> Function() onConfirmDelete;

  const AddonDeleteDialog({
    super.key,
    required this.addon,
    required this.onConfirmDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Addon addon,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AddonDeleteDialog(
        addon: addon,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<AddonDeleteDialog> createState() => _AddonDeleteDialogState();
}

class _AddonDeleteDialogState extends State<AddonDeleteDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirmDelete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.deleteAddonConfirmTitle,
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus add-on "${widget.addon.name}"?',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.deleteAddonConfirmMessage,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: AppTypography.label.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        AppButton(
          text: AppStrings.delete,
          variant: AppButtonVariant.destructive,
          isSolidDestructive: true,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleDelete,
        ),
      ],
    );
  }
}

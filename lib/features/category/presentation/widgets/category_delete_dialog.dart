import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/category.dart';

class CategoryDeleteDialog extends StatefulWidget {
  final Category category;
  final Future<void> Function() onConfirmDelete;

  const CategoryDeleteDialog({
    super.key,
    required this.category,
    required this.onConfirmDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Category category,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CategoryDeleteDialog(
        category: category,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<CategoryDeleteDialog> createState() => _CategoryDeleteDialogState();
}

class _CategoryDeleteDialogState extends State<CategoryDeleteDialog> {
  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirmDelete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      title: Text(
        AppStrings.deleteCategoryConfirmTitle,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 480),
        child: Text(
          AppStrings.deleteCategoryConfirmMessage,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
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
        AppButton(
          text: AppStrings.delete,
          variant: AppButtonVariant.destructive,
          isSolidDestructive: true,
          isLoading: _isLoading,
          onPressed: _delete,
        ),
      ],
    );
  }
}


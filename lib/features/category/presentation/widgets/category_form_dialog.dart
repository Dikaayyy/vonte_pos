import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/category.dart';
import '../../domain/validators/category_validator.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final Future<void> Function(String name) onSave;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Category? category,
    required Future<void> Function(String name) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CategoryFormDialog(
        category: category,
        onSave: onSave,
      ),
    );
  }

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validationError = CategoryValidator.validateName(_controller.text);
    if (validationError != null) {
      setState(() {
        _errorText = validationError;
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await widget.onSave(CategoryValidator.normalizeName(_controller.text));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString();
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
        _isEditing ? AppStrings.editCategory : AppStrings.addCategory,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AppStrings.categoryNameLabel,
              hint: AppStrings.categoryNameHint,
              controller: _controller,
              errorText: _errorText,
              enabled: !_isLoading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
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
        AppButton(
          text: AppStrings.save,
          variant: AppButtonVariant.primary,
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}


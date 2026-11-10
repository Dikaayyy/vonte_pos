import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/addon.dart';
import '../../domain/validators/addon_validator.dart';

class AddonFormDialog extends StatefulWidget {
  final Addon? addon;
  final Future<void> Function({
    required String name,
    required int price,
    required int stock,
  }) onSave;

  const AddonFormDialog({
    super.key,
    this.addon,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Addon? addon,
    required Future<void> Function({
      required String name,
      required int price,
      required int stock,
    }) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AddonFormDialog(
        addon: addon,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddonFormDialog> createState() => _AddonFormDialogState();
}

class _AddonFormDialogState extends State<AddonFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  String? _nameError;
  String? _priceError;
  String? _stockError;
  String? _generalError;
  bool _isLoading = false;

  bool get _isEditing => widget.addon != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addon?.name ?? '');
    _priceController = TextEditingController(
      text: widget.addon != null ? widget.addon!.price.toString() : '0',
    );
    _stockController = TextEditingController(
      text: widget.addon != null ? widget.addon!.stock.toString() : '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text;
    final priceStr = _priceController.text;
    final stockStr = _stockController.text;

    final nameErr = AddonValidator.validateName(name);
    final priceErr = AddonValidator.validatePrice(priceStr);
    final stockErr = AddonValidator.validateStock(stockStr);

    if (nameErr != null || priceErr != null || stockErr != null) {
      setState(() {
        _nameError = nameErr;
        _priceError = priceErr;
        _stockError = stockErr;
        _generalError = null;
      });
      return;
    }

    setState(() {
      _nameError = null;
      _priceError = null;
      _stockError = null;
      _generalError = null;
      _isLoading = true;
    });

    try {
      final parsedPrice = int.parse(priceStr.trim());
      final parsedStock = int.parse(stockStr.trim());

      await widget.onSave(
        name: AddonValidator.normalizeName(name),
        price: parsedPrice,
        stock: parsedStock,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = e.toString();
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
        _isEditing ? AppStrings.editAddon : AppStrings.addAddon,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: AppRadius.borderRadiusSm,
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    _generalError!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                controller: _nameController,
                label: AppStrings.addonNameLabel,
                hint: AppStrings.addonNameHint,
                errorText: _nameError,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _priceController,
                label: AppStrings.addonPriceLabel,
                hint: AppStrings.addonPriceHint,
                errorText: _priceError,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                onChanged: (_) {
                  if (_priceError != null) {
                    setState(() => _priceError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _stockController,
                label: AppStrings.addonStockLabel,
                hint: AppStrings.addonStockHint,
                errorText: _stockError,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_stockError != null) {
                    setState(() => _stockError = null);
                  }
                },
              ),
            ],
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
        const SizedBox(width: AppSpacing.xs),
        AppButton(
          text: AppStrings.save,
          variant: AppButtonVariant.primary,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}

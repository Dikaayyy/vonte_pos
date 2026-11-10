import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../addon/presentation/cubit/addon_cubit.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/photo_storage.dart';
import '../../domain/entities/product.dart';
import '../../domain/validators/product_validator.dart';
import 'product_image_view.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Future<void> Function({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds,
  }) onSave;
  final PhotoStorage? photoStorage;
  final AppImagePickerService? imagePickerService;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
    this.photoStorage,
    this.imagePickerService,
  });

  static Future<void> show(
    BuildContext context, {
    Product? product,
    required Future<void> Function({
      required String name,
      int? categoryId,
      required int price,
      required int stock,
      String? photoPath,
      List<int> addonIds,
    }) onSave,
    PhotoStorage? photoStorage,
    AppImagePickerService? imagePickerService,
    CategoryCubit? categoryCubit,
    AddonCubit? addonCubit,
  }) {
    CategoryCubit? resolvedCategoryCubit = categoryCubit;
    if (resolvedCategoryCubit == null) {
      try {
        resolvedCategoryCubit = context.read<CategoryCubit>();
      } catch (_) {}
    }

    AddonCubit? resolvedAddonCubit = addonCubit;
    if (resolvedAddonCubit == null) {
      try {
        resolvedAddonCubit = context.read<AddonCubit>();
      } catch (_) {}
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final dialog = ProductFormDialog(
          product: product,
          onSave: onSave,
          photoStorage: photoStorage,
          imagePickerService: imagePickerService,
        );

        final providers = <BlocProvider>[];
        if (resolvedCategoryCubit != null) {
          providers.add(
            BlocProvider<CategoryCubit>.value(value: resolvedCategoryCubit),
          );
        }
        if (resolvedAddonCubit != null) {
          providers.add(
            BlocProvider<AddonCubit>.value(value: resolvedAddonCubit),
          );
        }

        if (providers.isNotEmpty) {
          return MultiBlocProvider(
            providers: providers,
            child: dialog,
          );
        }
        return dialog;
      },
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  int? _selectedCategoryId;
  late final Set<int> _selectedAddonIds;

  File? _pickedPhotoFile;
  bool _removedPhoto = false;

  String? _nameError;
  String? _priceError;
  String? _stockError;
  String? _generalError;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.product != null ? widget.product!.stock.toString() : '0',
    );
    _selectedCategoryId = widget.product?.categoryId;
    _selectedAddonIds = Set<int>.from(widget.product?.addonIds ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  PhotoStorage get _storage =>
      widget.photoStorage ??
      (getIt.isRegistered<PhotoStorage>()
          ? getIt<PhotoStorage>()
          : throw Exception('PhotoStorage not available'));

  AppImagePickerService get _picker =>
      widget.imagePickerService ??
      (getIt.isRegistered<AppImagePickerService>()
          ? getIt<AppImagePickerService>()
          : throw Exception('AppImagePickerService not available'));

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final file = fromCamera
          ? await _picker.pickFromCamera()
          : await _picker.pickFromGallery();
      if (file != null && mounted) {
        setState(() {
          _pickedPhotoFile = file;
          _removedPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = 'Gagal memilih foto: $e';
        });
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _pickedPhotoFile = null;
      _removedPhoto = true;
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text;
    final priceStr = _priceController.text;
    final stockStr = _stockController.text;

    final nameErr = ProductValidator.validateName(name);
    final priceErr = ProductValidator.validatePrice(priceStr);
    final stockErr = ProductValidator.validateStock(stockStr);

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
      final parsedPrice = int.parse(priceStr.replaceAll('.', '').trim());
      final parsedStock = int.parse(stockStr.replaceAll('.', '').trim());

      String? finalPhotoPath;
      if (_pickedPhotoFile != null) {
        finalPhotoPath = await _storage.saveProductPhoto(_pickedPhotoFile!);
      } else if (_removedPhoto) {
        finalPhotoPath = null;
      } else {
        finalPhotoPath = widget.product?.photoPath;
      }

      await widget.onSave(
        name: name.trim(),
        categoryId: _selectedCategoryId,
        price: parsedPrice,
        stock: parsedStock,
        photoPath: finalPhotoPath,
        addonIds: _selectedAddonIds.toList(),
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
    final categories = context.watch<CategoryCubit?>()?.state.categories ?? [];
    final addons = context.watch<AddonCubit?>()?.state.addons ?? [];

    final hasPhoto = _pickedPhotoFile != null ||
        (!_removedPhoto &&
            widget.product?.photoPath != null &&
            widget.product!.photoPath!.isNotEmpty);

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
        _isEditing ? AppStrings.editProduct : AppStrings.addProduct,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
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

              // 1. Photo Picker section
              Text(
                AppStrings.productPhotoLabel,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.borderHairline,
                        width: 1,
                      ),
                    ),
                    child: ProductImageView(
                      photoPath:
                          _removedPhoto ? null : widget.product?.photoPath,
                      previewFile: _pickedPhotoFile,
                      productName: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Produk',
                      photoStorage: widget.photoStorage,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderRadiusMd,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.borderHairline,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  AppStrings.pickFromCamera,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () => _pickImage(true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderRadiusMd,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.borderHairline,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  AppStrings.pickFromGallery,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () => _pickImage(false),
                              ),
                            ),
                          ],
                        ),
                        if (hasPhoto) ...[
                          const SizedBox(height: AppSpacing.xs),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: Text(
                              AppStrings.removePhoto,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: _isLoading ? null : _removePhoto,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Product Name
              AppTextField(
                controller: _nameController,
                label: AppStrings.productNameLabel,
                hint: AppStrings.productNameHint,
                errorText: _nameError,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                onChanged: (_) {
                  setState(() {});
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Category Dropdown
              Text(
                AppStrings.productCategoryLabel,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Builder(
                builder: (context) {
                  final seenCategoryIds = <int?>{null};
                  final categoryItems = <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(AppStrings.uncategorized),
                    ),
                  ];
                  for (final cat in categories) {
                    if (seenCategoryIds.add(cat.id)) {
                      categoryItems.add(
                        DropdownMenuItem<int?>(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      );
                    }
                  }
                  if (_selectedCategoryId != null &&
                      !seenCategoryIds.contains(_selectedCategoryId)) {
                    categoryItems.add(
                      DropdownMenuItem<int?>(
                        value: _selectedCategoryId,
                        child: Text(
                          widget.product?.categoryName != null &&
                                  widget.product!.categoryName!.isNotEmpty
                              ? widget.product!.categoryName!
                              : 'Kategori ($_selectedCategoryId)',
                        ),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.borderHairline,
                        width: 1,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        borderRadius: AppRadius.borderRadiusMd,
                        items: categoryItems,
                        onChanged: _isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedCategoryId = val;
                                });
                              },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Price and Stock in a Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: AppStrings.productPriceLabel,
                      hint: AppStrings.productPriceHint,
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
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _stockController,
                      label: AppStrings.productStockLabel,
                      hint: AppStrings.productStockHint,
                      errorText: _stockError,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      onChanged: (_) {
                        if (_stockError != null) {
                          setState(() => _stockError = null);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. Add-ons Multi-Selection
              Text(
                AppStrings.productAddonsLabel,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (addons.isEmpty)
                Text(
                  AppStrings.noAddonsAvailable,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: addons.map((addon) {
                    final isSelected = _selectedAddonIds.contains(addon.id);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        '${addon.name} (+${formatRupiah(addon.price)})',
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      backgroundColor: AppColors.surfaceCard,
                      selectedColor: AppColors.primarySoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusFull,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderHairline,
                          width: 1,
                        ),
                      ),
                      onSelected: _isLoading
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAddonIds.add(addon.id);
                                } else {
                                  _selectedAddonIds.remove(addon.id);
                                }
                              });
                            },
                    );
                  }).toList(),
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


import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/services/photo_storage.dart';

class ProductImageView extends StatelessWidget {
  final String? photoPath;
  final String productName;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final PhotoStorage? photoStorage;
  final File? previewFile;

  const ProductImageView({
    super.key,
    required this.photoPath,
    required this.productName,
    this.width,
    this.height,
    this.borderRadius = AppRadius.borderRadiusMd,
    this.photoStorage,
    this.previewFile,
  });

  @override
  Widget build(BuildContext context) {
    if (previewFile != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          previewFile!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildLetterPlaceholder(),
        ),
      );
    }

    if (photoPath == null || photoPath!.trim().isEmpty) {
      return _buildLetterPlaceholder();
    }

    final storage = photoStorage ??
        (getIt.isRegistered<PhotoStorage>() ? getIt<PhotoStorage>() : null);

    if (storage == null) {
      return _buildLetterPlaceholder();
    }

    return FutureBuilder<File?>(
      future: storage.getPhotoFile(photoPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildLetterPlaceholder(),
            ),
          );
        }
        return _buildLetterPlaceholder();
      },
    );
  }

  Widget _buildLetterPlaceholder() {
    final firstLetter = productName.trim().isNotEmpty
        ? productName.trim().substring(0, 1).toUpperCase()
        : 'P';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderHairline, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: AppTypography.headlineLg.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

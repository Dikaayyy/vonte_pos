import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class AppImagePickerService {
  Future<File?> pickFromCamera({
    double maxWidth = 1024,
    int imageQuality = 85,
  });

  Future<File?> pickFromGallery({
    double maxWidth = 1024,
    int imageQuality = 85,
  });
}

class AppImagePickerServiceImpl implements AppImagePickerService {
  final ImagePicker _picker;

  AppImagePickerServiceImpl({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  @override
  Future<File?> pickFromCamera({
    double maxWidth = 1024,
    int imageQuality = 85,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  @override
  Future<File?> pickFromGallery({
    double maxWidth = 1024,
    int imageQuality = 85,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }
}


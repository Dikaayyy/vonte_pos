import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

import '../../../../core/storage/app_directory_provider.dart';

abstract class PhotoStorage {
  Future<String> saveProductPhoto(File sourceFile);

  Future<String?> resolvePhotoPath(String? relativePath);

  Future<File?> getPhotoFile(String? relativePath);

  Future<void> deletePhoto(String? relativePath);
}

class PhotoStorageImpl implements PhotoStorage {
  final AppDirectoryProvider _directoryProvider;
  final Random _random;

  PhotoStorageImpl(
    this._directoryProvider, {
    Random? random,
  }) : _random = random ?? Random();

  static const String productImagesFolder = 'product_images';

  @override
  Future<String> saveProductPhoto(File sourceFile) async {
    final docDir = await _directoryProvider.getApplicationDocumentsDirectory();
    final targetFolder = Directory(p.join(docDir.path, productImagesFolder));
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path).toLowerCase()
        : '.jpg';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(100000).toString().padLeft(5, '0');
    final fileName = 'prod_${timestamp}_$randomSuffix$ext';

    final targetPath = p.join(targetFolder.path, fileName);
    await sourceFile.copy(targetPath);

    return p.join(productImagesFolder, fileName).replaceAll(r'\', '/');
  }

  @override
  Future<String?> resolvePhotoPath(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) {
      return null;
    }
    final docDir = await _directoryProvider.getApplicationDocumentsDirectory();
    return p.join(docDir.path, relativePath);
  }

  @override
  Future<File?> getPhotoFile(String? relativePath) async {
    final absolutePath = await resolvePhotoPath(relativePath);
    if (absolutePath == null) {
      return null;
    }
    final file = File(absolutePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  Future<void> deletePhoto(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) {
      return;
    }
    try {
      final absolutePath = await resolvePhotoPath(relativePath);
      if (absolutePath != null) {
        final file = File(absolutePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {
      // Deletion failure should not crash transaction or UI flow
    }
  }
}


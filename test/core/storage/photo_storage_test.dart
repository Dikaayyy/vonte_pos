import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/storage/app_directory_provider.dart';
import 'package:vonte_pos/features/product/data/services/photo_storage.dart';

class FakeDirectoryProvider implements AppDirectoryProvider {
  final Directory tempDirectory;

  FakeDirectoryProvider(this.tempDirectory);

  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return tempDirectory;
  }
}

void main() {
  late Directory tempDir;
  late FakeDirectoryProvider directoryProvider;
  late PhotoStorageImpl photoStorage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vonte_pos_test_');
    directoryProvider = FakeDirectoryProvider(tempDir);
    photoStorage = PhotoStorageImpl(directoryProvider);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PhotoStorage', () {
    test('saveProductPhoto copies source file to product_images and returns relative path', () async {
      final sourceFile = File('${tempDir.path}/temp_source.jpg');
      await sourceFile.writeAsString('fake_image_bytes');

      final relativePath = await photoStorage.saveProductPhoto(sourceFile);

      expect(relativePath.startsWith('product_images/'), isTrue);
      expect(relativePath.endsWith('.jpg'), isTrue);

      final absolutePath = await photoStorage.resolvePhotoPath(relativePath);
      expect(absolutePath, isNotNull);
      expect(File(absolutePath!).existsSync(), isTrue);
      expect(await File(absolutePath).readAsString(), 'fake_image_bytes');
    });

    test('resolvePhotoPath returns null for null or empty relative path', () async {
      expect(await photoStorage.resolvePhotoPath(null), isNull);
      expect(await photoStorage.resolvePhotoPath(''), isNull);
      expect(await photoStorage.resolvePhotoPath('   '), isNull);
    });

    test('getPhotoFile returns File when file exists, and null when file is missing (file hilang)', () async {
      final sourceFile = File('${tempDir.path}/test_image.png');
      await sourceFile.writeAsString('sample_png');

      final relativePath = await photoStorage.saveProductPhoto(sourceFile);

      // File exists
      final existingFile = await photoStorage.getPhotoFile(relativePath);
      expect(existingFile, isNotNull);
      expect(await existingFile!.exists(), isTrue);

      // Now simulate missing file (user deleted cache/file externally)
      await existingFile.delete();

      // Must return null instead of throwing or crashing
      final missingFile = await photoStorage.getPhotoFile(relativePath);
      expect(missingFile, isNull);
    });

    test('deletePhoto removes the target photo file from disk', () async {
      final sourceFile = File('${tempDir.path}/sample.jpg');
      await sourceFile.writeAsString('test_bytes');

      final relativePath = await photoStorage.saveProductPhoto(sourceFile);
      final fileBefore = await photoStorage.getPhotoFile(relativePath);
      expect(fileBefore, isNotNull);

      await photoStorage.deletePhoto(relativePath);

      final fileAfter = await photoStorage.getPhotoFile(relativePath);
      expect(fileAfter, isNull);
    });

    test('deletePhoto handles null, empty, or non-existent files gracefully without exception', () async {
      await expectLater(photoStorage.deletePhoto(null), completes);
      await expectLater(photoStorage.deletePhoto(''), completes);
      await expectLater(photoStorage.deletePhoto('product_images/non_existent.jpg'), completes);
    });
  });
}


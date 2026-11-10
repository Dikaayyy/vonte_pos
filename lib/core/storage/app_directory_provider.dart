import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

abstract class AppDirectoryProvider {
  Future<Directory> getApplicationDocumentsDirectory();
}

class AppDirectoryProviderImpl implements AppDirectoryProvider {
  const AppDirectoryProviderImpl();

  @override
  Future<Directory> getApplicationDocumentsDirectory() {
    return path_provider.getApplicationDocumentsDirectory();
  }
}


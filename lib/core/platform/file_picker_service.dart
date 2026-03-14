import 'package:file_picker/file_picker.dart';

abstract class FilePickerService {
  Future<List<PlatformFile>?> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  });
}

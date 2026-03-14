import 'package:file_picker/file_picker.dart';
import 'file_picker_service.dart';

class FilePickerMobile implements FilePickerService {
  @override
  Future<List<PlatformFile>?> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );

    return result?.files;
  }
}

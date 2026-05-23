import 'package:file_picker/file_picker.dart';

class WatermarkImagePicker {
  WatermarkImagePicker({FilePicker? filePicker})
    : _filePicker = filePicker ?? FilePicker.platform;

  final FilePicker _filePicker;

  Future<String?> pickImagePath() async {
    final result = await _filePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    return result?.files.single.path;
  }
}

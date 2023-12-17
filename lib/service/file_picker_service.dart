import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      final files = result.paths.map((path) => File(path!)).toList();
      print(files);
    } else {
      // User canceled the picker
    }
  }
}

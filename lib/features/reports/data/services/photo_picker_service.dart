import 'package:image_picker/image_picker.dart';

import 'package:found_it/features/reports/domain/entities/report_image.dart';

abstract class PhotoPickerService {
  Future<ReportImage?> pickImage({required ImageSource source});
}

class PhotoPickerServiceImpl implements PhotoPickerService {
  final ImagePicker _picker;

  PhotoPickerServiceImpl([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  @override
  Future<ReportImage?> pickImage({required ImageSource source}) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final name = file.name.isNotEmpty
        ? file.name
        : file.path.split('/').last.split('\\').last;

    return ReportImage(name: name, bytes: bytes);
  }
}

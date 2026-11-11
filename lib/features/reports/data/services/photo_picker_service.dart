import 'package:image_picker/image_picker.dart';

abstract class PhotoPickerService {
  Future<XFile?> pickImage({required ImageSource source});
}

class PhotoPickerServiceImpl implements PhotoPickerService {
  final ImagePicker _picker;

  PhotoPickerServiceImpl([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  @override
  Future<XFile?> pickImage({required ImageSource source}) =>
      _picker.pickImage(source: source);
}

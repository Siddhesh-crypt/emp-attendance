import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker picker = ImagePicker();

  Future<String?> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }
}

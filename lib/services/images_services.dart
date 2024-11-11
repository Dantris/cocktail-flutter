import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String> captureImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85, // Optional: Adjust image quality
      );

      if (pickedFile == null) {
        throw Exception("No image selected");
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final localImage = await File(pickedFile.path)
          .copy('$path/${basename(pickedFile.path)}');

      return localImage.path;
    } catch (e) {
      throw Exception("Failed to capture image: $e");
    }
  }
}

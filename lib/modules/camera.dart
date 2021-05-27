import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CameraModule {
  final picker = ImagePicker();
  File _image;
  Uri _uploadUrl = Uri.parse(env['FILE_UPLOAD_URL']);

  Future<File> getImageGallery() async {
    try {
      final imageFile = await picker.getImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 50, //1-100
      );

      if (imageFile == null) return null;

      _image = File(imageFile.path);

      return _image;
    } catch (e) {
      throw e;
    }
  }

  Future<File> getImageCamera([
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  ]) async {
    try {
      final imageFile = await picker.getImage(
        source: ImageSource.camera,
        maxWidth: 600,
        imageQuality:
            preferredCameraDevice == CameraDevice.front ? 100 : 50, //1-100
        preferredCameraDevice: preferredCameraDevice,
      );

      if (imageFile == null) return null;

      _image = File(imageFile.path);

      return _image;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> getImageUrl([File img]) async {
    try {
      final image = img == null ? await getImageGallery() : img;

      if (image == null) return;

      String base64Image = base64Encode(image.readAsBytesSync());

      final res = await http.post(_uploadUrl, body: {"image": base64Image});
      final data = json.decode(res.body)["data"];

      return data;
    } catch (e) {
      throw e;
    }
  }
}

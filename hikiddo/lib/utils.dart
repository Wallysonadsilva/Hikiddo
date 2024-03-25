import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List> pickUpImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  } else {
    print("No image selected");
    return Uint8List(0); // Return an empty Uint8List or handle the absence of an image accordingly
  }
}
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikiddo/constants.dart';
import 'package:http/http.dart' as http;

//https://stackoverflow.com/questions/56597739/how-to-customize-google-maps-marker-icon-in-flutter

  Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
}


Future<BitmapDescriptor> getMarkerIcon1(String assetPath, Size size) async {
  // Step 1: Load the image data from assets
  ByteData data = await rootBundle.load(assetPath);
Uint8List imgBytes = data.buffer.asUint8List();
ui.Codec codec = await ui.instantiateImageCodec(imgBytes, targetWidth: size.width.toInt(), targetHeight: size.height.toInt()); // Ensure the image fits your size requirements
ui.FrameInfo fi = await codec.getNextFrame();
  // Step 2: Draw custom elements and the image onto a canvas
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Radius radius = Radius.circular(size.width / 2);

  // Your custom drawing logic here...
    const double shadowWidth = 15.0;
    final Paint borderPaint = Paint()..color = Colors.white;
    final Paint tagPaint = Paint()..color = Colors.blue;
    const double tagWidth = 40.0;
    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);

  // Oval for the image
  // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width - tagWidth,
              0.0,
              tagWidth,
              tagWidth
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

// Oval for the image
  Rect oval = Rect.fromLTWH(
    15.0 + 3.0, // shadowWidth + borderWidth
    15.0 + 3.0, // shadowWidth + borderWidth
    size.width - ((15.0 + 3.0) * 2), // size.width - (shadowWidth + borderWidth) * 2
    size.height - ((15.0 + 3.0) * 2)); // size.height - (shadowWidth + borderWidth) * 2

  // Clip and draw the image within the oval
  canvas.clipPath(Path()..addOval(oval));
  canvas.drawImage(fi.image, const Offset(15.0 + 3.0, 15.0 + 3.0), Paint());

  // Step 3: Convert the canvas drawing to an image and then to bytes
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  // Step 4: Create a BitmapDescriptor from the image bytes
  return BitmapDescriptor.fromBytes(uint8List);
}

Future<BitmapDescriptor> getMarkerIconFromUrl(String imageUrl, Size size) async {
  // Download image data from the URL
  final response = await http.get(Uri.parse(imageUrl));
  final Uint8List imageData = response.bodyBytes;

  // Prepare a recorder to record the canvas operations
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Radius radius = Radius.circular(size.width / 2);

  // Your custom drawing logic here...
  const double shadowWidth = 15.0;
  final Paint borderPaint = Paint()..color = Colors.white;
  final Paint tagPaint = Paint()..color = greenColor;
  const double tagWidth = 40.0;
  final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);

  // Add shadow circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            0.0,
            0.0,
            size.width,
            size.height
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      shadowPaint);

  // Add border circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            shadowWidth,
            shadowWidth,
            size.width - (shadowWidth * 2),
            size.height - (shadowWidth * 2)
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      borderPaint);

  // Add tag circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            size.width - tagWidth,
            0.0,
            tagWidth,
            tagWidth
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      tagPaint);

  // Decode the image from the data
  ui.Codec codec = await ui.instantiateImageCodec(imageData, targetWidth: size.width.toInt(), targetHeight: size.height.toInt());
  ui.FrameInfo fi = await codec.getNextFrame();

  // Oval for the image
  Rect oval = Rect.fromLTWH(
      shadowWidth + borderPaint.strokeWidth, // X position
      shadowWidth + borderPaint.strokeWidth, // Y position
      size.width - ((shadowWidth + borderPaint.strokeWidth) * 2), // Width
      size.height - ((shadowWidth + borderPaint.strokeWidth) * 2)); // Height

  // Clip and draw the image within the oval
  canvas.clipPath(Path()..addOval(oval));
  canvas.drawImage(fi.image, Offset(shadowWidth + borderPaint.strokeWidth, shadowWidth + borderPaint.strokeWidth), Paint());

  // Convert the canvas drawing to an image, then to bytes
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  // Create a BitmapDescriptor from the image bytes
  return BitmapDescriptor.fromBytes(uint8List);
}


Future<BitmapDescriptor> getMarkerIconFromUrl1(String imageUrl, Size size) async {
  try {
    // Attempt to download the image from the URL
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List imageData = response.bodyBytes;
      // Decode the image and prepare for custom drawing
      ui.Codec codec = await ui.instantiateImageCodec(imageData, targetWidth: size.width.toInt(), targetHeight: size.height.toInt());
      ui.FrameInfo fi = await codec.getNextFrame();

      // Proceed with custom drawing logic similar to before...
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final paint = Paint();
      final radius = Radius.circular(size.width / 2);
      final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final RRect rrect = RRect.fromRectAndCorners(rect, topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius);

      // Clip the image to a circular shape and draw it
      canvas.clipRRect(rrect);
      canvas.drawImage(fi.image, Offset.zero, paint);

      // Convert canvas to image
      final ui.Image markerImage = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
      // Convert image to bytes
      final ByteData? byteData = await markerImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8List = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(uint8List);
    } else {
      // Log or handle HTTP response error
      print('Failed to download the image, HTTP status code: ${response.statusCode}');
      
    }
  } catch (e) {
    // Log or handle any errors in fetching or processing the image
    print('Error fetching or processing the image: $e');
  }
  // Return a default marker in case of failure
  return BitmapDescriptor.defaultMarker;
}

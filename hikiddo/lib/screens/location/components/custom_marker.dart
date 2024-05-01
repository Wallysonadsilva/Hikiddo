import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikiddo/constants.dart';
import 'package:http/http.dart' as http;

// Code reused from:
//https://stackoverflow.com/questions/56597739/how-to-customize-google-maps-marker-icon-in-flutter


Future<BitmapDescriptor> getMarkerIconFromUrl( String imageUrl, Size size) async {
  // Download image data from the URL
  final response = await http.get(Uri.parse(imageUrl));
  final Uint8List imageData = response.bodyBytes;

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Radius radius = Radius.circular(size.width / 2);

  // Custom drawing logic here...
  const double shadowWidth = 15.0;
  final Paint borderPaint = Paint()..color = Colors.white;
  final Paint tagPaint = Paint()..color = greenColor;
  const double tagWidth = 40.0;
  final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);

  // Add shadow circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      shadowPaint);

  // Add border circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(shadowWidth, shadowWidth, size.width - (shadowWidth * 2),
            size.height - (shadowWidth * 2)),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      borderPaint);

  // Add tag circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      tagPaint);

  // Decode the image from the data
  ui.Codec codec = await ui.instantiateImageCodec(imageData,
      targetWidth: size.width.toInt(), targetHeight: size.height.toInt());
  ui.FrameInfo fi = await codec.getNextFrame();

  // Oval for the image
  Rect oval = Rect.fromLTWH(
      shadowWidth + borderPaint.strokeWidth, // X position
      shadowWidth + borderPaint.strokeWidth, // Y position
      size.width - ((shadowWidth + borderPaint.strokeWidth) * 2), // Width
      size.height - ((shadowWidth + borderPaint.strokeWidth) * 2)); // Height

  // Clip and draw the image within the oval
  canvas.clipPath(Path()..addOval(oval));
  canvas.drawImage(
      fi.image,
      Offset(shadowWidth + borderPaint.strokeWidth,
          shadowWidth + borderPaint.strokeWidth),
      Paint());

  // Convert the canvas drawing to an image, then to bytes
  final ui.Image markerAsImage = await pictureRecorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  // Create a BitmapDescriptor from the image bytes
  return BitmapDescriptor.fromBytes(uint8List);
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/memoryboard/components/background.dart';
import 'package:hikiddo/services/database.dart';
import 'package:hikiddo/services/media_storage.dart';
import 'package:image_picker/image_picker.dart'; // Ensure you have added image_picker in your pubspec.yaml

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final MediaDataServices _mediaDataServices = MediaDataServices();
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  String? familyGroupId;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchFamilyGroupId(); // Fetch the familyGroupId as soon as the widget initializes
  }

  Future<void> fetchFamilyGroupId() async {
    String? id = await _databaseService.getFamilyGroupId(context);
    if (id != null) {
      setState(() {
        familyGroupId = id;
      });
    }
  }

  Future<void> _fetchAndUpdateImages() async {
    if (familyGroupId != null) {
      var imageUrls =
          await _mediaDataServices.fetchMemoryBoardImages(familyGroupId!);
      setState(() {
        _imageUrls = imageUrls;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List fileBytes = await image.readAsBytes();
      String fileName = image.name;
      await _mediaDataServices.uploadMemoryBoardImage(
          fileBytes, fileName, familyGroupId!);
      _fetchAndUpdateImages();
    }
  }

  Future<void> _takeNewPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Uint8List fileBytes = await photo.readAsBytes();
      String fileName = photo.name;
      await _mediaDataServices.uploadMemoryBoardImage(
          fileBytes, fileName, familyGroupId!);
      _fetchAndUpdateImages();
    }
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: GestureDetector(
            onTap: () => Navigator.pop(context), // Close the dialog on tap
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    // Fetch and update images when the family group ID is available.
    if (familyGroupId != null && _imageUrls.isEmpty) {
      _fetchAndUpdateImages();
    }

    return Scaffold(
        appBar: TopNavigationBar(showBackButton: true),
        body: Background(
          child: familyGroupId == null
              ? const Center(child: Text("Loading..."))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            "Family Memories",
                            style: TextStyle(
                                color:
                                    redColor, // Use your redColor variable here
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.photo_album_rounded, size: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      // Correct use of Expanded to fill available space for GridView
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: _imageUrls.isEmpty
                              ? const Center(child: Text("No images found"))
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Function to call when the image is tapped
                                        _showFullImageDialog(
                                            context, _imageUrls[index]);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            _imageUrls[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                    ),
                  ],
                ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _pickImageFromGallery,
              tooltip: 'Pick Image from Gallery',
              heroTag: 'Pick Image from Gallery',
              child: const Icon(Icons.photo_library),
            ),
            const SizedBox(width: 20), // Space between buttons
            FloatingActionButton(
              onPressed: _takeNewPhoto,
              tooltip: 'Take Photo',
              heroTag: 'Take Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ));
  }
}

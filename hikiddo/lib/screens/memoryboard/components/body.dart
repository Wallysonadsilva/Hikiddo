import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/mediatype.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/memoryboard/components/background.dart';
import 'package:hikiddo/services/database.dart';
import 'package:hikiddo/services/media_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  List<MediaItem> _mediaItems =
      []; // Updated to mediaUrls to include both images and videos

  @override
  void initState() {
    super.initState();
    fetchFamilyGroupId();
  }

  Future<void> fetchFamilyGroupId() async {
    String? id = await _databaseService.getFamilyGroupId(context);
    if (id != null) {
      setState(() {
        familyGroupId = id;
      });
      _fetchAndUpdateMedia();
    }
  }

  Future<void> _fetchAndUpdateMedia() async {
    if (familyGroupId != null) {
      var mediaItems =
          await _mediaDataServices.fetchMemoryBoardMedia(familyGroupId!);
      setState(() {
        _mediaItems = mediaItems;
      });
    }
  }


Future<void> _pickMediaFromGallery() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.media,
    allowMultiple: false,
  );

  if (result != null) {
    final path = result.files.single.path;
    final fileName = result.files.single.name;

    if (path != null) {
      final fileBytes = await File(path).readAsBytes();
      final isVideo = ['mp4', 'mov'].contains(result.files.single.extension);

      // Inform the user that the upload is starting
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading file...')),
      );

      try {
        await _mediaDataServices.uploadMemoryBoardMedia(
            fileBytes, fileName, familyGroupId!, isVideo);
        _fetchAndUpdateMedia(); // Refresh the media displayed in the UI
        if(!mounted) return;
        // Inform the user of success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
      } catch (e) {


        // Inform the user of failure
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file.')),
        );
      }
    } else {
      print("File path is null");
    }
  } else {
    print("No file selected");
  }
}





  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Uint8List fileBytes = await photo.readAsBytes();
      String fileName = photo.name;
      await _mediaDataServices.uploadMemoryBoardMedia(fileBytes, fileName,
          familyGroupId!, false); // false indicating it's not a video
      _fetchAndUpdateMedia(); // Refresh the media displayed in the UI
    }
  }

  Future<void> _captureVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      Uint8List fileBytes = await video.readAsBytes();
      String fileName = video.name;
      await _mediaDataServices.uploadMemoryBoardMedia(fileBytes, fileName,
          familyGroupId!, true); // true indicating it's a video
      _fetchAndUpdateMedia(); // Refresh the media displayed in the UI
    }
  }

  Widget _imageThumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
    );
  }

  Future<Widget> _videoThumbnail(String url) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128, // You can adjust the size
        quality: 25,
      );

      if (thumbnailData != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(thumbnailData, fit: BoxFit.cover),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.error, color: Colors.white, size: 40),
          ),
        );
      }
    } catch (e) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.error, color: Colors.white, size: 40),
        ),
      );
    }
  }
Future<void> _playVideo(Uri url) async {
  VideoPlayerController videoPlayerController = VideoPlayerController.networkUrl(url);
  await videoPlayerController.initialize();
  videoPlayerController.play();

  if(!mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside it
    builder: (_) => AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero, // Removes padding around the dialog content
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          videoPlayerController.addListener(() {
            final bool isEnded = videoPlayerController.value.position >= videoPlayerController.value.duration - const Duration(milliseconds: 500); // Adding a small buffer to ensure the end of the video is detected accurately
            if (isEnded) {
              setState(() {});
            }
          });

          return Stack(
            alignment: Alignment.topRight, // Aligns the close button to the top right
            children: [
              AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(videoPlayerController),
                    if (videoPlayerController.value.position >= videoPlayerController.value.duration - const Duration(milliseconds: 500))
                      GestureDetector(
                        onTap: () {
                          videoPlayerController.seekTo(Duration.zero); // Rewind the video to the beginning
                          videoPlayerController.play(); // Play the video again
                          setState(() {});
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: const Icon(Icons.replay, size: 60.0, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30.0, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
  ).then((_) {
    videoPlayerController.dispose(); // Dispose of the controller when the dialog is closed
  });
}


  @override
  Widget build(BuildContext context) {
    // Fetch and update images when the family group ID is availab
    return Scaffold(
      appBar: TopNavigationBar(showBackButton: true),
      body: familyGroupId == null ? const JoinFamilyScreen() : Background(
        child: familyGroupId == null
            ? const Center(child: Text("Loading..."))
            : Column(
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Family Memories",
                      style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: redColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _mediaItems.isEmpty
                        ? const Center(child: Text("No media found"))
                        : Container(
                            padding: const EdgeInsets.all(9.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: _mediaItems.length,
                              itemBuilder: (context, index) {
                                final mediaItem = _mediaItems[index];
                                Uri videoUri = Uri.parse(mediaItem.url);
                                return GestureDetector(
                                  onTap: () => mediaItem.isVideo
                                      ? _playVideo(videoUri)
                                      : _showFullImageDialog(
                                          context, mediaItem.url),
                                  child: mediaItem.isVideo
                                      ? FutureBuilder<Widget>(
                                          future:
                                              _videoThumbnail(mediaItem.url),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<Widget> snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData) {
                                              // Wrap the snapshot.data in a container to ensure it fills the space
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                clipBehavior: Clip
                                                    .antiAlias, // Ensures the content is clipped to the border radius
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Positioned.fill(
                                                      // This will ensure the thumbnail image fills the container
                                                      child: snapshot
                                                          .data!, // Assuming this is an Image widget
                                                    ),
                                                    // Semi-transparent overlay to improve the visibility of the icon
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons
                                                            .play_circle_outline,
                                                        color: Colors.white,
                                                        size: 40), // Play icon
                                                  ],
                                                ),
                                              );
                                            } else {
                                              // Loading or error state
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.black38,
                                                ),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      : _imageThumbnail(mediaItem
                                          .url), // Display image thumbnail for non-video items
                                );
                              },
                            )),
                  ),
                ],
              ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _pickMediaFromGallery,
            heroTag: 'gallery',
            tooltip: 'Add from Gallery',
            child: const Icon(
              Icons.photo_library,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _capturePhoto,
            heroTag: 'camera',
            tooltip: 'Use Camera',
            child: const Icon(
              Icons.camera_alt,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _captureVideo,
            heroTag: 'video',
            tooltip: 'Record Video',
            child: const Icon(
              Icons.videocam,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  // Here you can return any placeholder widget
                  return const Icon(
                      Icons.broken_image); // Placeholder icon for errors
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

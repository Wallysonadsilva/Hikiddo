import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/services/database.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/voice_recording.dart';
import 'package:hikiddo/screens/memoryboard/components/background.dart';
import 'package:hikiddo/services/media_storage.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final MediaDataServices _mediaDataServices = MediaDataServices();
  final DatabaseService _databaseService = DatabaseService();
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  bool isRecording = false; // Tracks recording state
  List<VoiceRecording> recordings = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;
  String? hostId;
  String? familyGroupId;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (user != null) {
        _databaseService.getFamilyGroupId(context).then((familyGroupId) {
          if (familyGroupId != null) {
            _fetchAndStoreHostId(familyGroupId);
            _initLoadRecordings();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _soundRecorder.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: TopNavigationBar(showBackButton: true),
        body: familyGroupId == null
            ? const JoinFamilyScreen()
            : Background(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Storyteller',
                        style: TextStyle(
                            color: redColor,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView.builder(
                          itemCount: recordings.length,
                          itemBuilder: (context, index) {
                            final recording = recordings[index];
                            final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            final bool canEdit = recording.userId == currentUserId || hostId == currentUserId;
                            String formattedDate = DateFormat(
                                    'dd-MM-yyyy – kk:mm')
                                .format(recording.date
                                    .toLocal()); // Adjust based on your date type

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date: $formattedDate",
                                          style: const TextStyle(
                                              color: orangeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: "Title: ",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: recording.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .normal,
                                                      color:
                                                          greenColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if(canEdit)
                                              TextButton.icon(
                                                onPressed: () => _editTitleDialog(recordings[index]),
                                                icon: const Icon(Icons.edit_note,
                                                color: Colors.grey),
                                                label: const Text(""),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _currentlyPlayingUrl ==
                                              recordings[index].fileUrl
                                          ? Icons.stop
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () => _togglePlayStop(
                                        recordings[index].fileUrl),
                                  ),
                                  if (canEdit)
                                    IconButton(
                                        onPressed: () =>
                                            _confirmDeleteRecording(
                                                recording.id),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: redColor,
                                        ))
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton:  familyGroupId != null ? FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: _toggleRecording,
          child: Icon(
            isRecording ? Icons.stop : Icons.mic,
            color: Colors.red,
          ),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> _initRecorder() async {
    final permissionStatus = await Permission.microphone.request();
    if (permissionStatus != PermissionStatus.granted) {
      print('Microphone permission not granted');
    }
    await _soundRecorder.openAudioSession();
  }

  Future<void> _toggleRecording() async {
    if (_soundRecorder.isRecording) {
      // Stop the recorder and obtain the path of the recorded file
      final String? recordingPath = await _soundRecorder.stopRecorder();
      setState(() => isRecording = false);

      if (recordingPath != null) {
        // Read the file as a Uint8List
        final recordingData = await File(recordingPath).readAsBytes();

        String title = "Add Title";
        // ignore: use_build_context_synchronously
        String? familyGroupId = await _databaseService.getFamilyGroupId(context);

        // Save the recording to Firebase
        await _mediaDataServices.saveRecording(
            recordingData, title, familyGroupId!);
        print("Recording saved successfully");
        await _initLoadRecordings();
      }
    } else {
      // Define the file path where the recording will be saved
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
      // Start the recorder
      await _soundRecorder.startRecorder(toFile: filePath);
      setState(() => isRecording = true);
    }
  }

  Future<void> _playRecording(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _currentlyPlayingUrl = url);
    } catch (e) {
      print("Error playing audio: $e");
      setState(() {});
    }
  }

  Future<void> _togglePlayStop(String url) async {
    if (_currentlyPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingUrl = null);
    } else {
      await _audioPlayer.stop(); // Ensure any current playback is stopped
      await _playRecording(url); // The _currentlyPlayingUrl will be set within _playRecording
    }
  }

  Future<void> _initLoadRecordings() async {
    familyGroupId = await _databaseService.getFamilyGroupId(context);
    if (familyGroupId != null) {
      try {
        await _loadRecordings( familyGroupId!);
      } catch (e) {
        print("Failed to load recordings: $e");
      }
    } else {
      print("Family group ID is null");
    }
  }

  Future<void> _loadRecordings(String groupId) async {
    recordings = await _mediaDataServices.fetchRecordings(groupId);
  }

  Future<void> _editTitleDialog(VoiceRecording recording) async {
    TextEditingController titleController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter new title",
                    ),
                    maxLength: 20, // Set the maximum length
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _saveNewTitle(recording.id, titleController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNewTitle(String recordingId, String newTitle) async {
    try {
      await _mediaDataServices.updateRecordingTitle(recordingId, newTitle);
      setState(() {
        var recording = recordings.firstWhere((rec) => rec.id == recordingId);
        recording.title = newTitle;
      });
    } catch (e) {
      print("Error saving new title: $e");
    }
  }

  Future<void> _confirmDeleteRecording(String recordingId) async {
    // Show confirmation dialog
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete Recording'),
            content: const Text(
                'Are you sure you want to delete this recording? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      _deleteRecording(recordingId);
    }
  }

  Future<void> _fetchAndStoreHostId(String familyGroupId) async {
    String? id = await _databaseService.getFamilyGroupHostId(context, familyGroupId);
    if (mounted) {
      setState(() {
        hostId = id;
      });
    }
  }

  Future<void> _deleteRecording(String recordingId) async {
    try {
      final String fileUrl = recordings
          .firstWhere((recording) => recording.id == recordingId)
          .fileUrl;
      await _mediaDataServices.deleteRecording(recordingId, fileUrl);
      setState(() {
        recordings.removeWhere((recording) => recording.id == recordingId);
      });
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }
}

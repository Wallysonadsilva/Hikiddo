import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/screens/profile/components/background.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';
import 'package:hikiddo/services/database.dart';
import 'package:hikiddo/services/media_storage.dart';
import 'package:hikiddo/utils.dart';
import 'package:image_picker/image_picker.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  Uint8List? _image;
  // ignore: unused_field
  bool _isUploading = false;
  String? _imageURL;

  @override
  void initState() {
    super.initState();
    loadUserProfilePic();
  }

  void loadUserProfilePic() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = userDoc.data();
      if (userDoc.exists &&
          data is Map<String, dynamic> &&
          data.containsKey('imageLink')) {
        setState(() {
          _imageURL = data['imageLink'];
        });
      }
    }
  }

  void selectImage() async {
    Uint8List img = await pickUpImage(ImageSource.gallery, context);
    // After the async gap, check if the widget is still mounted
    if (!mounted) return;

    if (img.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No image selected or failed to pick an image.")),
      );
      return;
    }

    setState(() {
      _image = img;
      _isUploading = true; // Begin the upload process
    });

    // Ensure you check for 'mounted' state again if there's another async operation and you need to call setState afterwards.
    saveProfilePic();
  }

  void saveProfilePic() async {
    if (_image == null) {
      return; // Do nothing if there's no image
    }
    try {
      String resp = await MediaDataServices().savaData(
          file:
              _image!); // Assuming a typo in 'savaData' corrected to 'saveData'
      if (!mounted) return; // Check if the widget is still mounted
      if (resp == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully")),
        );
        if (!mounted) return; // Check again as `loadUserProfilePic` might also be async
        loadUserProfilePic();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile picture")),
        );
        // Handle failure, inform the user (considering the widget is still mounted here)
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error during image upload")),
      );
      // Handle error, inform the user (considering the widget is still mounted here)
    } finally {
      if (mounted) {
        // Ensure widget is still in the tree before calling setState
        setState(() {
          _isUploading = false; // Reset upload state
        });
      }
    }
  }


 void _deleteAccount(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user logged in.")),
      );
      return;
    }

    // Remove user from Firestore family group
    await FirebaseFirestore.instance
        .collection('familyGroup')
        .where('members', arrayContains: uid)
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({
              'members': FieldValue.arrayRemove([uid])
            });
          }
        });

    // Remove user's document from the users collection
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // Delete user account
    await user!.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account deleted successfully")),
    );

    // Optionally, navigate the user away to a "login" or "welcome" screen
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );


  } catch (e) {
    print("Error deleting account: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete account")),
    );
  }
}

  Widget _userInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding:
            const EdgeInsets.all(8.0), // Add some padding inside the container
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: greenColor,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showEditDialog(
                context,
                label,
                value,
                (newValue) {
                  // Handle the new value here
                  // _updateUserInfo(label, newValue);
                },
              ),
              child: const Icon(Icons.edit, color: orangeColor),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _showEditDialog(BuildContext context, String label,
      String initialValue, Function(String) onConfirm) async {
    TextEditingController controller = TextEditingController(text: initialValue);
    // Define a local GlobalKey for this specific dialog instance
    final GlobalKey<FormState> _formKeyDialog = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: Form(
            key: _formKeyDialog,  // Use the local GlobalKey here
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: "Enter new $label"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label cannot be empty';
                }
                if (label == 'Name' && !RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
                  return "Names can only contain letters";
                  }
                if (label == "Email" && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                if (label == "Phone Number" && !RegExp(r'^(\+44\s?7\d{3}|\(?07\d{3}\)?)\s?\d{3}\s?\d{3}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
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
                if (_formKeyDialog.currentState!.validate()) {  // Make sure to reference the local form key
                  String uid = FirebaseAuth.instance.currentUser!.uid; // Ensure the user is logged in
                  String fieldToUpdate = _getFieldKeyFromLabel(label);

                  if (fieldToUpdate.isNotEmpty) {
                    DatabaseService dbService = DatabaseService(uid: uid);

                    dbService.safeUpdateUserDataField(uid, fieldToUpdate, controller.text)
                        .then((_) {
                          onConfirm(controller.text); // Call onConfirm with the new value
                          Navigator.of(context).pop(); // Close the dialog
                        })
                        .catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error updating data: $error")),
                          );
                        });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }



// Helper function to map labels to field names
String _getFieldKeyFromLabel(String label) {
  switch (label) {
    case 'Name':
      return 'name';
    case 'Email':
      return 'email';
    case 'Phone Number':
      return 'phoneNumber';
    default:
      return '';
  }
}


  @override
  Widget build(BuildContext context) {
    // Build method moved inside the state class
    return PopScope(canPop: false,
      child: Background(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4), // Size of the border
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors
                          .transparent, // Ensure the Container background is transparent
                      border: Border.all(
                        color: greenColor
                            .withOpacity(0.5), // Blue border with 50% opacity
                        width: 4, // Border thickness
                      ),
                    ),
                    child: _imageURL != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(_imageURL!),
                          )
                        : const CircleAvatar(
                            radius: 64.0,
                            backgroundImage: NetworkImage(
                                'https://t3.ftcdn.net/jpg/02/09/37/00/360_F_209370065_JLXhrc5inEmGl52SyvSPeVB23hB6IjrR.jpg'),
                            backgroundColor: Colors.transparent,
                          ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: yellowColor,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<Profile>(
                stream:
                    DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid)
                        .currentUserProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData) {
                    return const Text("No profile found");
                  }
                  Profile profile = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _userInfoRow("Name", profile.name.toString(), context),
                        _userInfoRow("Email", profile.email.toString(), context),
                        _userInfoRow("Phone Number",
                            profile.phoneNumber.toString(), context),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              RoundButton(
                text: 'Delete My Account',
                press: () => _deleteAccount(context),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

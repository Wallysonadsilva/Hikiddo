import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/screens/profile/components/background.dart';
import 'package:hikiddo/services/database.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  // Future or Stream to fetch profiles will be defined here
  String obscuredPassword = '••••••';

  @override
  Widget build(BuildContext context) {
    // Build method moved inside the state class
    return Background(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              backgroundColor: Colors.transparent,
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
                  // Use SingleChildScrollView for a single item or just directly return your widgets
                  child: Column(
                    children: [
                      _userInfoRow("Name", profile.name.toString(), context),
                      _userInfoRow("Email", profile.email.toString(), context),
                      _userInfoRow("Phone Number",
                          profile.phoneNumber.toString(), context),
                      _userInfoRow("Password", obscuredPassword, context),
                      // Add other fields as needed
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Ensure '_userInfoRow' accepts 'context' as an argument
  Widget _userInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: $value', style: const TextStyle(fontSize: 16)),
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
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  // '_showEditDialog' method here as previously defined
  Future<void> _showEditDialog(BuildContext context, String label,
      String initialValue, Function(String) onConfirm) async {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter new $label"),
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
              onPressed: () async {
                String uid = FirebaseAuth
                    .instance.currentUser!.uid; // Ensure the user is logged in
                String fieldToUpdate = _getFieldKeyFromLabel(label);

                if (fieldToUpdate.isNotEmpty) {
                  // Instantiate DatabaseService with the current user's UID
                  DatabaseService dbService = DatabaseService(uid: uid);

                  await dbService
                      .safeUpdateUserDataField(
                          uid, fieldToUpdate, controller.text)
                      .then((_) {
                    onConfirm(
                        controller.text); // Call onConfirm with the new value
                    // Optionally, refresh data or provide user feedback
                  }).catchError((error) {
                    // Handle or log the error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating data: $error")),
                    );
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/joinfamily/components/background.dart';
import 'package:hikiddo/screens/mainscreen/main_screen.dart';
import 'package:hikiddo/services/database.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  Timer? _debounce;

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _controller.text;
      if (query.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      _databaseService.searchGroups(query).then((groups) {
        final suggestions = [...groups];
        if (!groups.contains(query)) {
          suggestions.add("Create new: \"$query\"");
        }
        setState(() => _suggestions = suggestions);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _tryCreateGroup(String groupName) async {
    final result = await _databaseService.createGroup(groupName);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      // Optionally, navigate to the new group's page or refresh the group list
    } else {
      // Show alert dialog on failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Notice'),
            content: Text(result.message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the alert dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Join a family group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              controllers: _controller, // Corrected to match the property name
              icon: Icons.search,
              iconColor: Colors.grey,
              hintText: "Search or Create New",
              onChanged: (value) {},
            ),
            // Check if the suggestions list is not empty to display the instructions and the list
            if (_suggestions.isNotEmpty)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Tap on a group to join, or tap "Create new: \'Group Name\'" to start a new group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap:
                        true, // Necessary to embed ListView inside Column/SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scroll inside scroll
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return RoundButton(
                        text: suggestion,
                        color: greenColor,
                        press: () async {
                            if (suggestion.startsWith("Create new:")) {
                              final groupName = suggestion
                                  .replaceFirst("Create new: \"", "")
                                  .replaceAll("\"", "");
                              _tryCreateGroup(groupName);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const MainScreen();
                                  },
                                ),
                              );
                            } else {
                              // Retrieve the groupId based on the group name
                              String? groupId = await _databaseService
                                  .getFamilyGroupIdFromName(suggestion);
                              if (groupId != null) {
                                _databaseService.joinGroup(groupId).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "You've joined the group successfully")),
                                  );
                                  // Navigate to home page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const MainScreen();
                                      },
                                    ),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Failed to join group: $error")),
                                  );
                                });
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Group not found")),
                                );
                              }
                            }
                          },
                        );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            SizedBox(height: size.height * 0.25),
          ],
        ),
      ),
    );
  }
}

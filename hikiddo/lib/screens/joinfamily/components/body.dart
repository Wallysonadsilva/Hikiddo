// ignore_for_file: use_build_context_synchronously, duplicate_ignore
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Background(
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
                controllers:
                    _controller, // Corrected to match the property name
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
                          true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
                          child: RoundButton(
                            text: suggestion,
                            color: greenColor,
                            press: () async {
                              if (suggestion.startsWith('Create new:')) {
                                final groupName = suggestion
                                    .replaceFirst('Create new: \'', '')
                                    .replaceAll('\'', '');
                                createGroup(groupName);
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
                                    .getFamilyGroupIdFromName(
                                        context, suggestion);
                                if (groupId != null) {
                                  // Instead of joining the group, send a join request
                                  await _databaseService
                                      .sendJoinRequest(
                                          groupId,
                                          FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .then((_) {
                                    _joinRequestDialog(context);

                                    // Optionally, navigate back or to another relevant screen
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to send join request: $error')),
                                    );
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Group not found')),
                                  );
                                }
                              }
                            },
                          ),
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
      ),
    );
  }

  void createGroup(String groupName) async {
    final result = await _databaseService.createGroup(groupName);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } else {
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
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

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
          suggestions.add('Create new: \'$query\'');
        }
        setState(() => _suggestions = suggestions);
      });
    });
  }

  Future<void> _joinRequestDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Request'),
          content: const Text(
            'Your join request has been sent.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const MainScreen();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/screens/homepage/components/background.dart';
import 'package:hikiddo/screens/profile_22/components/profile_list.dart';
import 'package:hikiddo/services/auth.dart';
import 'package:hikiddo/services/database.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  Body({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Profile>?>.value(
        value: DatabaseService().users,
        initialData: null,
        child: Background(
          child: Column(children: <Widget>[
            const Expanded(
              child: ProfileList(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("Settings"),
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Modal BottomSheet'),
                                ElevatedButton(
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ));
                    });
              },
            ),
          ]),
        ));
  }
}

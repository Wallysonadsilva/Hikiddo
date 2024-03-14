import 'package:flutter/material.dart';
import 'package:hikiddo/models/profile.dart';

class ProfileTile extends StatelessWidget {

  final Profile? profile;
  const ProfileTile({
    super.key,
    this.profile
  });

  @override
  Widget build(BuildContext context) {

    String profileName = profile?.name ?? 'Default Name';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: const CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.white,
          ),
          title: Text(profileName),
        ),
      ),
    );
  }
}
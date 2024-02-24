import 'package:flutter/material.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/screens/profile/components/profile_tile.dart';
import 'package:provider/provider.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({super.key});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  @override
  Widget build(BuildContext context) {

    final users = Provider.of<List<Profile>?>(context);

    users?.forEach((users) {
      print(users.name);
    });

    return ListView.builder(
      itemCount: users?.length,
      itemBuilder: (context, index){
        return ProfileTile(profile: users?[index]);
      }
    );
  }
}
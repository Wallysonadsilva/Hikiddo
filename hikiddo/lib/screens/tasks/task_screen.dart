import 'package:flutter/material.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/tasks/components/body.dart';
import 'package:hikiddo/services/database.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: DatabaseService().getFamilyGroupId(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: TopNavigationBar(showBackButton: true),
            body: const JoinFamilyScreen(),
          );
        }
        return Scaffold(
          body: Body(familyGroupId: snapshot.data!),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/familygroup/components/background.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/mainscreen/main_screen.dart';
import 'package:hikiddo/services/database.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final DatabaseService _databaseService =
      DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid);
  String? familyGroupId;
  String newMemberID = "";

  @override
  void initState() {
    super.initState();
    _fetchFamilyGroupId();
  }

  Future<void> _fetchFamilyGroupId() async {
    String? id = await _databaseService.getFamilyGroupId(context);
    if (id != null) {
      setState(() {
        familyGroupId = id;
      });
    }
  }

  Future<void> confirmeAndRemoveMember(
      String memberId, String removeMessage) async {
    // Show confirmation dialog
    final bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Removal'),
              content: Text(removeMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // User cancels
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // User confirms
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false; // Handle the case where showDialog returns null (dialog dismissed)

    // Proceed with removal if confirmed
    if (confirmed && familyGroupId != null) {
      try {
        await _databaseService.removeMemberFromFamilyGroup(
            familyGroupId!, memberId);
        // Remove group ID from the user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .update({
          'familyGroupId': FieldValue.delete(),
        });

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member removed successfully')));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to remove member: $error')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: TopNavigationBar(showBackButton: true),
      body: familyGroupId == null
          ? const JoinFamilyScreen()
          : Background(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Text(
                    "Family Group",
                    style: TextStyle(
                        color: redColor,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('familyGroup')
                          .doc(familyGroupId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: Text("No data found"));
                        }
                        var groupData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        List<dynamic> members = groupData['members'];
                        bool isHost = FirebaseAuth.instance.currentUser?.uid ==
                            groupData['hostId'];
                        return ListView(
                          children: [
                            ListTile(
                              title: Text(
                                groupData['name'],
                                style: const TextStyle(
                                    color: greenColor,
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                "Members:",
                                style: TextStyle(
                                    color: redColor,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                              subtitle: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                height: 250,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: members
                                        .map((memberId) =>
                                            FutureBuilder<DocumentSnapshot>(
                                              future: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(memberId)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Text(
                                                      "Loading...");
                                                }
                                                newMemberID = memberId;
                                                var userData =
                                                    snapshot.data!.data()
                                                        as Map<String, dynamic>;
                                                return ListTile(
                                                  leading: const Icon(
                                                      Icons.person,
                                                      color: Colors.black),
                                                  title: Text(
                                                    userData['name'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: isHost &&
                                                          memberId !=
                                                              groupData[
                                                                  'hostId']
                                                      ? TextButton(
                                                          onPressed: () =>
                                                              confirmeAndRemoveMember(
                                                                  memberId,
                                                                  'Are you sure you want to remove this member from the Family group?'),
                                                          child: const Text(
                                                              "Remove",
                                                              style: TextStyle(
                                                                  color:
                                                                      redColor)),
                                                        )
                                                      : null,
                                                );
                                              },
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                            if (!isHost)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    confirmeAndRemoveMember(newMemberID,
                                        'Are you sure you want to leave this Family group?');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(100, 55),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: const Text("Leave Group"),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(100, 55),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: const Text("Delete Group"),
                                ),
                              )
                          ],
                        );
                      },
                    ),
                  ),
                  Positioned(
                      child: Image.asset(
                    "assets/images/joinFamily_bottom.png",
                    width: size.width * 0.8,
                  )),
                ],
              ),
            ),
    );
  }
}

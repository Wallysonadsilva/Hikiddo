import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/familygroup/components/background.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/mainscreen/main_screen.dart';
import 'package:hikiddo/screens/wrapper.dart';
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

  void showJoinRequestsDialog(String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pending Join Requests'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Adjust the height as needed
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('familyGroup')
                  .doc(groupId)
                  .collection('joinRequests')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    // Use a FutureBuilder to fetch user details
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(doc.id)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Loading...'),
                          );
                        }
                        Map<String, dynamic> userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        String userName = userData['name'] ??
                            'Unknown User'; // Assuming 'name' field exists in user documents
                        return ListTile(
                          title: Text(
                              'Request from $userName'), // Display fetched user name
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () async {
                                  await _databaseService.approveJoinRequest(
                                      groupId, doc.id);
                                  if (context.mounted)
                                    Navigator.of(dialogContext).pop();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  await _databaseService.denyJoinRequest(
                                      groupId, doc.id);
                                  if (context.mounted)
                                    Navigator.of(dialogContext).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
      child: Scaffold(
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
                              snapshot.data?.data() as Map<String, dynamic>?;
                          if (groupData == null) {
                            return const Center(
                                child: Text(
                                    "No data found or data is not in expected format."));
                          } else {
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
                              // Overlay the badge on top of the button
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
                                  height: 300,
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
                                                  if (!snapshot.hasData ||
                                                      snapshot.data?.data() ==
                                                          null) {
                                                    return const Text(
                                                        "Loading...");
                                                  }
                                                  // Since we now know snapshot.data is not null, we can safely access it
                                                  var userData = snapshot.data!
                                                          .data()
                                                      as Map<String, dynamic>?;
                                                  // Check if userData is null before accessing it
                                                  if (userData == null) {
                                                    return const Text(
                                                        "User data not found.");
                                                  }
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 14.0, top: 8.0, bottom: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _deleteFamilyGroup(
                                                context, familyGroupId);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: redColor,
                                            foregroundColor: Colors.white,
                                            // Removed minimumSize to allow the button to fill the Expanded widget
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 20),
                                          ),
                                          child: const Text("Delete Group"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8.0, right: 23),
                                        child: Stack(
                                          alignment: Alignment
                                              .centerRight, // Adjust the Stack alignment as needed
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  showJoinRequestsDialog(
                                                      familyGroupId!),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: greenColor,
                                                foregroundColor: Colors.white,
                                                // Removed minimumSize to allow the button to fill the Expanded widget
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 22,
                                                        vertical: 20),
                                              ),
                                              child:
                                                  const Text("Manage Requests"),
                                            ),
                                            Positioned(
                                              top:
                                                  -5, // Adjust the badge position as needed
                                              right: 10,
                                              child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection('familyGroup')
                                                    .doc(familyGroupId)
                                                    .collection('joinRequests')
                                                    .where('status',
                                                        isEqualTo: 'pending')
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Container(); // Or some loading indicator
                                                  }
                                                  int pendingRequestsCount =
                                                      snapshot.data!.docs.length;
                                                  return pendingRequestsCount > 0
                                                      ? Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Text(
                                                            '$pendingRequestsCount',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 12),
                                                          ),
                                                        )
                                                      : Container(); // Return an empty container if there are no pending requests
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

void _deleteFamilyGroup(BuildContext context, String? familyGroupId) async {
  if (familyGroupId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid Family Group ID")),
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;
  try {
    WriteBatch batch = firestore.batch();

    // Explicitly delete the family group document
    DocumentReference groupRef =
        firestore.collection('familyGroup').doc(familyGroupId);
    batch.delete(groupRef);

    // Delete tasks
    var tasksSnapshot = await firestore
        .collection('tasks')
        .where('familyGroupId', isEqualTo: familyGroupId)
        .get();
    for (var task in tasksSnapshot.docs) {
      batch.delete(task.reference);
    }

    // Update or delete familyGroupId in users' documents
    var usersSnapshot = await firestore
        .collection('users')
        .where('familyGroupId', isEqualTo: familyGroupId)
        .get();
    for (var doc in usersSnapshot.docs) {
      batch.update(doc.reference, {'familyGroupId': FieldValue.delete()});
    }

    // Commit all deletions
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text("Family group and all related data deleted successfully")),
    );

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const Wrapper()),
    );
  } catch (e) {
    print("Error when deleting family group and related data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete family group and related data")),
    );
  }
}

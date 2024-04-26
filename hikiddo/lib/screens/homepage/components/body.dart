import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/screens/familygroup/familygroup.dart';
import 'package:hikiddo/screens/homepage/components/background.dart';
import 'package:hikiddo/components/dashboard_center_squares.dart';
import 'package:hikiddo/screens/memoryboard/memory_board.dart';
import 'package:hikiddo/screens/tasks/task_screen.dart';
import 'package:hikiddo/screens/voicerecord/voice_recording.dart';
import 'package:hikiddo/services/database.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final DatabaseService databaseService =
      DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid);
  String? familyGroupId;

  @override
  void initState() {
    super.initState();
    _fetchFamilyGroupId();
  }

  Future<void> _fetchFamilyGroupId() async {
    String? id = await databaseService.getFamilyGroupId(context);
    if (id != null) {
      setState(() {
        familyGroupId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Background(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              Wrap(
                spacing: 8.0,
                alignment:
                    WrapAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const MemoryBoardPage();
                          },
                        ),
                      );
                    },
                    child: const DashboardSquare(
                      cardText: "Memories",
                      imagePath: "assets/images/memoryboard.png",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const RecordVoicePage();
                          },
                        ),
                      );
                    },
                    child: const DashboardSquare(
                      cardText: "Storyteller",
                      imagePath: "assets/images/joinFamily_bottom.png",
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0, // Space between the DashboardSquares
                alignment:
                    WrapAlignment.center, // Center the squares within the Wrap
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const TaskScreen();
                          },
                        ),
                      );
                    },
                    child: const DashboardSquare(
                      cardText: "Challenges",
                      imagePath: "assets/images/challenges.png",
                    ),
                  ),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const FamilyGroupPage();
                              },
                            ),
                          );
                        },
                        child: const DashboardSquare(
                          cardText: "Family Group",
                          imagePath: "assets/images/joinFamily_bottom.png",
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 13,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('familyGroup')
                              .doc(familyGroupId)
                              .collection('joinRequests')
                              .where('status', isEqualTo: 'pending')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            int pendingRequestsCount =
                                snapshot.data!.docs.length;
                            return pendingRequestsCount > 0
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Text(
                                      '$pendingRequestsCount',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  )
                                : Container();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

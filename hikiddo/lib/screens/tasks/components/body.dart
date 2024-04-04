// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/task.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/tasks/components/background.dart';
import 'package:hikiddo/services/database.dart';

class Body extends StatefulWidget {
  final String familyGroupId;
  const Body({super.key, required this.familyGroupId});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final DatabaseService _databaseService = DatabaseService();
  bool _currentUserIsHost = false;
  String? familyGroupId;

  @override
  void initState() {
    super.initState();
    _checkIfHost();
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

  void _checkIfHost() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    String? hostId = await _databaseService.getFamilyGroupHostId(
        context, widget.familyGroupId);
    setState(() {
      _currentUserIsHost = currentUserId == hostId;
    });
  }

  void showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController pointsController = TextEditingController();

    // Function to show a SnackBar with an error message
    void showErrorSnackBar(String message) {
      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Optional: customize your SnackBar color
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: "Task Title"),
                ),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(hintText: "Task Points"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final String title = titleController.text.trim();
                final String pointsText = pointsController.text.trim();
                final int? points = int.tryParse(pointsText);

                if (title.isEmpty) {
                  showErrorSnackBar("Please enter a task title.");
                  return; // Keep the dialog open
                }

                if (points == null) {
                  showErrorSnackBar("Please enter a valid number for points.");
                  return; // Keep the dialog open
                }

                // If input is valid, proceed to add the task
                _databaseService
                    .addTask(widget.familyGroupId, title, points)
                    .then((_) {
                  Navigator.of(context).pop(); // Close the dialog upon success
                }).catchError((error) {
                  showErrorSnackBar("Failed to add task: $error");
                  // Optionally, keep the dialog open if the task fails to add
                });
              },
            ),
          ],
        );
      },
    );
  }

  bool resetPoints = false;
  bool clearReward = false;

  void showSetRewardDialog() {
    final TextEditingController rewardTitleController = TextEditingController();
    final TextEditingController rewardDescriptionController =
        TextEditingController();

    // Reset checkboxes state every time the dialog is opened
    resetPoints = false;
    clearReward = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update dialog's state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Weekly Reward'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    if (!clearReward) ...[
                      TextField(
                        controller: rewardTitleController,
                        decoration:
                            const InputDecoration(hintText: "Reward Title"),
                      ),
                      TextField(
                        controller: rewardDescriptionController,
                        decoration: const InputDecoration(
                            hintText: "Reward Description"),
                      ),
                    ],
                    CheckboxListTile(
                      value: resetPoints,
                      onChanged: (bool? value) {
                        setState(() => resetPoints = value!);
                      },
                      title: const Text("Reset members points"),
                    ),
                    CheckboxListTile(
                      value: clearReward,
                      onChanged: (bool? value) {
                        setState(() {
                          clearReward = value!;
                          // Optionally clear input fields when choosing to clear the reward
                          if (clearReward) {
                            rewardTitleController.clear();
                            rewardDescriptionController.clear();
                          }
                        });
                      },
                      title: const Text("Clear current reward"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () async {
                    try {
                      if (clearReward) {
                        // Logic to clear the reward
                        await _databaseService.setWeeklyReward(
                            widget.familyGroupId, "", "");
                      } else {
                        // Logic to set a new reward, if fields are not empty
                        if (rewardTitleController.text.isNotEmpty &&
                            rewardDescriptionController.text.isNotEmpty) {
                          await _databaseService.setWeeklyReward(
                            widget.familyGroupId,
                            rewardTitleController.text,
                            rewardDescriptionController.text,
                          );
                        }
                      }
                      if (resetPoints) {
                        // Logic to reset points
                        await _databaseService
                            .resetFamilyGroupPoints(widget.familyGroupId);
                      }
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(" Rewards Updated")),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update: $error")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updatePointsAndDeleteCompletedTasks() async {
    // This will hold the total points earned from the completed tasks
    int totalPointsEarned = 0;

    // Fetch the current list of tasks
    final tasksSnapshot =
        await _databaseService.getFamilyGroupTasks(widget.familyGroupId).first;
    final List<Task> tasks = tasksSnapshot;

    // Filter out the completed tasks and calculate total points
    final List<Task> completedTasks =
        tasks.where((task) => task.status).toList();
    for (final task in completedTasks) {
      totalPointsEarned += task.points;
    }

    // Update the user's points in Firestore
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _databaseService
          .updateUserPoints(userId, totalPointsEarned)
          .catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating user points: $error")));
      });
    }

    // Delete the completed tasks from Firestore
    for (final task in completedTasks) {
      await _databaseService.deleteTask(task.id).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting task ${task.id}: $error")));
      });
    }

    // Optional: Show a confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Points updated and completed tasks deleted.')));
    }

    // Optional: Refresh the list of tasks to reflect the changes
    setState(() {});
  }

  void showScoreboardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Family Group Scoreboard'),
          content: SizedBox(
            // Set a fixed height or make it scrollable if needed
            height: 300,
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('familyGroupId', isEqualTo: widget.familyGroupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No family members found'));
                }
                List<DocumentSnapshot> userDocs = snapshot.data!.docs;
                return ListView(
                  children: userDocs.map((doc) {
                    Map<String, dynamic> userData =
                        doc.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(userData['name'] ?? 'No Name'),
                      trailing: Text('${userData['points'] ?? 0} points'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopNavigationBar(showBackButton: true),
      body: SizedBox(
        height: size.height,
        width: size.height,
        child: familyGroupId == null
            ? const JoinFamilyScreen()
            : Background(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      "Challenges",
                      style: TextStyle(
                          color: redColor,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    if (userId != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          var userDoc =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          int points = userDoc?['points'] ?? 0;
                          return Text("Your Points: $points");
                        },
                      ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    if (_currentUserIsHost)
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Adjust spacing as needed
                        children: [
                          FloatingActionButton(
                            onPressed: showAddTaskDialog,
                            backgroundColor: Colors.white,
                            tooltip: 'Add Task',
                            heroTag: 'Add Task',
                            child: const Icon(
                              Icons.add,
                              color: yellowColor,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          FloatingActionButton(
                            onPressed: showSetRewardDialog,
                            backgroundColor: Colors.white,
                            tooltip: 'Set Weekly Reward',
                            heroTag: 'Set Weekly Reward',
                            child: const Icon(
                              Icons.card_giftcard,
                              color: redColor,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          FloatingActionButton(
                            onPressed: showScoreboardDialog,
                            backgroundColor: Colors.white,
                            tooltip: 'View Scoreboard',
                            heroTag: 'View Scoreboard',
                            child: const Icon(
                              Icons.scoreboard,
                              color: orangeColor,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _databaseService.groupCollection
                          .doc(widget.familyGroupId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Text("Loading reward...");
                        var data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        String weeklyRewardTitle =
                            data?['weeklyRewardTitle'] ?? 'No Reward Set';
                        String weeklyRewardDescription =
                            data?['weeklyRewardDescription'] ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reward: $weeklyRewardTitle",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Description: $weeklyRewardDescription",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "Tasks",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: redColor),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 350, // Fixed height for the container
                      width: double
                          .infinity, // Container takes the full width of its parent
                      child: SingleChildScrollView(
                        // Allows scrolling within the fixed height container
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: StreamBuilder<List<Task>>(
                          stream: _databaseService.getFamilyGroupTasks(
                              widget.familyGroupId) as Stream<List<Task>>?,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: Text('No tasks found'));
                            }
                            List<Task> tasks = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap:
                                  true, // Important to ensure the ListView occupies minimum space
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  activeColor: yellowColor,
                                  title: Text('- ${tasks[index].title}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic)),
                                  value: tasks[index].status,
                                  onChanged: (bool? value) {
                                    if (value == null) return;
                                    final taskId = tasks[index].id;
                                    final currentStatus = tasks[index].status;
                                    setState(() {
                                      tasks[index].status = value;
                                    });
                                    _databaseService
                                        .taskStatus(taskId, currentStatus)
                                        .catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Failed to toggle task status: $error")));
                                      setState(() {
                                        tasks[index].status = !value;
                                      });
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    RoundButton(
                      text: "Update",
                      press: updatePointsAndDeleteCompletedTasks,
                      color: greenColor,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

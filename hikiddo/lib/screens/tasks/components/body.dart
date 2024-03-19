import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/models/task.dart';
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

  @override
  void initState() {
    super.initState();
    _checkIfHost();
  }

  void _checkIfHost() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    String? hostId =
        await _databaseService.getFamilyGroupHostId(widget.familyGroupId);
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

  bool shouldResetPoints = false;
bool shouldClearReward = false;

void showSetRewardDialog() {
    final TextEditingController rewardTitleController = TextEditingController();
    final TextEditingController rewardDescriptionController = TextEditingController();

    // Reset checkboxes state every time the dialog is opened
    shouldResetPoints = false;
    shouldClearReward = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog's state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Weekly Reward'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    if (!shouldClearReward) ...[ // Hide input fields if clearing reward
                      TextField(
                        controller: rewardTitleController,
                        decoration: const InputDecoration(hintText: "Reward Title"),
                      ),
                      TextField(
                        controller: rewardDescriptionController,
                        decoration: const InputDecoration(hintText: "Reward Description"),
                      ),
                    ],
                    CheckboxListTile(
                      value: shouldResetPoints,
                      onChanged: (bool? value) {
                        setState(() => shouldResetPoints = value!);
                      },
                      title: const Text("Reset members points"),
                    ),
                    CheckboxListTile(
                      value: shouldClearReward,
                      onChanged: (bool? value) {
                        setState(() {
                          shouldClearReward = value!;
                          // Optionally clear input fields when choosing to clear the reward
                          if (shouldClearReward) {
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
                      if (shouldClearReward) {
                        // Logic to clear the reward
                        await _databaseService.setWeeklyReward(widget.familyGroupId, "", "");
                      } else {
                        // Logic to set a new reward, if fields are not empty
                        if (rewardTitleController.text.isNotEmpty && rewardDescriptionController.text.isNotEmpty) {
                          await _databaseService.setWeeklyReward(
                            widget.familyGroupId,
                            rewardTitleController.text,
                            rewardDescriptionController.text,
                          );
                        }
                      }
                      if (shouldResetPoints) {
                        // Logic to reset points
                        await _databaseService.resetFamilyGroupPoints(widget.familyGroupId);
                      }

                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text(" Rewards Updated")),
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
        print("Error updating user points: $error");
      });
    }

    // Delete the completed tasks from Firestore
    for (final task in completedTasks) {
      await _databaseService.deleteTask(task.id).catchError((error) {
        print("Error deleting task ${task.id}: $error");
      });
    }

    // Optional: Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Points updated and completed tasks deleted.')));

    // Optional: Refresh the list of tasks to reflect the changes
    setState(() {});
  }

  void showScoreboardDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Family Group Scoreboard'),
        content: Container(
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
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No family members found'));
              }
              List<DocumentSnapshot> userDocs = snapshot.data!.docs;
              return ListView(
                children: userDocs.map((doc) {
                  Map<String, dynamic> userData = doc.data()! as Map<String, dynamic>;
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

    return Scaffold(
      appBar: TopNavigationBar(showBackButton: true),
      body: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            "Weekly Mission",
            style: TextStyle(
                color: redColor, fontSize: 28.0, fontWeight: FontWeight.bold),
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
                var userDoc = snapshot.data?.data() as Map<String, dynamic>?;
                int points = userDoc?['points'] ?? 0;
                return Text("Your Points: $points");
              },
            ),
          const SizedBox(
            height: 20.0,
          ),
          if (_currentUserIsHost)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Adjust spacing as needed
              children: [
                FloatingActionButton(
                  onPressed: showAddTaskDialog,
                  backgroundColor: Colors.white,
                  tooltip: 'Add Task',
                  heroTag: 'Add Task',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                FloatingActionButton(
                  onPressed: showSetRewardDialog,
                  backgroundColor: Colors.white,
                  tooltip: 'Set Weekly Reward',
                  heroTag: 'Set Weekly Reward',
                  child: const Icon(Icons.card_giftcard),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                FloatingActionButton(
                  onPressed: showScoreboardDialog,
                  backgroundColor: Colors.white,
                  tooltip: 'View Scoreboard',
                  heroTag: 'View Scoreboard',
                  child: const Icon(Icons.scoreboard),
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
              if (!snapshot.hasData) return const Text("Loading reward...");
              var data = snapshot.data!.data() as Map<String, dynamic>?;
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
                fontSize: 22, fontWeight: FontWeight.bold, color: redColor),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _databaseService.getFamilyGroupTasks(widget.familyGroupId)
                  as Stream<List<Task>>?,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No tasks found'));
                }
                List<Task> tasks = snapshot.data!;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(tasks[index].title),
                      value: tasks[index].status,
                      onChanged: (bool? value) {
                        if (value == null) return; // Ignore nulls for safety

                        final taskId = tasks[index].id;
                        final currentStatus = tasks[index].status;

                        // Optimistically update the UI
                        setState(() {
                          tasks[index].status = value;
                        });

                        // Attempt to toggle the status in Firestore
                        _databaseService
                            .taskStatus(taskId, currentStatus)
                            .catchError((error) {
                          // If an error occurs, log it and optionally revert the UI change
                          print("Failed to toggle task status: $error");
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
          RoundButton(
            text: "Update",
            press: updatePointsAndDeleteCompletedTasks,
            color: greenColor,
          )
        ],
      ),
    );
  }
}

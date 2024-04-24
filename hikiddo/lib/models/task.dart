class Task {
  String id;
  String title;
  int points;
  bool status;
  String? completedBy;

  Task({
    required this.id,
    required this.title,
    required this.points,
    this.status = false,
    this.completedBy,
  });

  //factory constructor
  factory Task.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      points: data['points'] ?? 0,
      status: data['status'] ?? false,
      completedBy: data['completedBy'],
    );
  }

  // method to convert a Task object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'points': points,
      'status': status,
      'completedBy': completedBy,
    };
  }
}

class VoiceRecording {
  String id;
  String title;
  DateTime date;
  String fileUrl;
  String familyGroupId;
  String userId;

  VoiceRecording({
    required this.id,
    required this.title,
    required this.date,
    required this.fileUrl,
    required this.familyGroupId,
    required this.userId
  });

  factory VoiceRecording.fromFirestore(Map<String, dynamic> data, String id) {
    return VoiceRecording(
      id: id,
      title: data['title'],
      date: data['date'].toDate(),
      fileUrl: data['fileUrl'],
      familyGroupId: data['familyGroupId'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'fileUrl': fileUrl,
      'familyGroupId': familyGroupId,
      'userId': userId
    };
  }
}

class NoticeModel {
  final String id;
  final String landlordId;
  final String title;
  final String body;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      landlordId: map['landlordId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
    'landlordId': landlordId,
    'title': title,
    'body': body,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}
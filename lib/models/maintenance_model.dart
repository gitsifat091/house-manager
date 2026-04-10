enum MaintenanceStatus { pending, inProgress, done }

class MaintenanceModel {
  final String id;
  final String tenantId;
  final String tenantName;
  final String roomNumber;
  final String propertyId;
  final String propertyName;
  final String landlordId;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final DateTime createdAt;

  MaintenanceModel({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.roomNumber,
    required this.propertyId,
    required this.propertyName,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory MaintenanceModel.fromMap(Map<String, dynamic> map, String id) {
    MaintenanceStatus status;
    switch (map['status']) {
      case 'inProgress': status = MaintenanceStatus.inProgress; break;
      case 'done': status = MaintenanceStatus.done; break;
      default: status = MaintenanceStatus.pending;
    }
    return MaintenanceModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      landlordId: map['landlordId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: status,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
    'tenantId': tenantId,
    'tenantName': tenantName,
    'roomNumber': roomNumber,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'landlordId': landlordId,
    'title': title,
    'description': description,
    'status': status == MaintenanceStatus.inProgress
        ? 'inProgress'
        : status == MaintenanceStatus.done
            ? 'done'
            : 'pending',
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  String get statusLabel {
    switch (status) {
      case MaintenanceStatus.inProgress: return 'কাজ চলছে';
      case MaintenanceStatus.done: return 'সম্পন্ন';
      default: return 'অপেক্ষমাণ';
    }
  }

  String get statusColorHex {
    switch (status) {
      case MaintenanceStatus.inProgress: return '1D9E75';
      case MaintenanceStatus.done: return '185FA5';
      default: return 'BA7517';
    }
  }
}
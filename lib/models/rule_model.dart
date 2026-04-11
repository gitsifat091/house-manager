enum RuleCategory { house, legal, payment, maintenance }

class RuleModel {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final RuleCategory category;
  final bool isActive;
  final DateTime createdAt;

  RuleModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.category,
    this.isActive = true,
    required this.createdAt,
  });

  factory RuleModel.fromMap(Map<String, dynamic> map, String id) {
    RuleCategory cat;
    switch (map['category']) {
      case 'legal': cat = RuleCategory.legal; break;
      case 'payment': cat = RuleCategory.payment; break;
      case 'maintenance': cat = RuleCategory.maintenance; break;
      default: cat = RuleCategory.house;
    }
    return RuleModel(
      id: id,
      landlordId: map['landlordId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: cat,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
    'landlordId': landlordId,
    'title': title,
    'description': description,
    'category': category == RuleCategory.legal
        ? 'legal'
        : category == RuleCategory.payment
            ? 'payment'
            : category == RuleCategory.maintenance
                ? 'maintenance'
                : 'house',
    'isActive': isActive,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  String get categoryLabel {
    switch (category) {
      case RuleCategory.legal: return 'আইনী অধিকার';
      case RuleCategory.payment: return 'ভাড়া সংক্রান্ত';
      case RuleCategory.maintenance: return 'রক্ষণাবেক্ষণ';
      default: return 'বাড়ির নিয়ম';
    }
  }

  String get categoryIcon {
    switch (category) {
      case RuleCategory.legal: return '⚖️';
      case RuleCategory.payment: return '💰';
      case RuleCategory.maintenance: return '🔧';
      default: return '🏠';
    }
  }

  String get categoryColorHex {
    switch (category) {
      case RuleCategory.legal: return 'FF1565C0';
      case RuleCategory.payment: return 'FF2E7D32';
      case RuleCategory.maintenance: return 'FFE65100';
      default: return 'FF6A1B9A';
    }
  }
}
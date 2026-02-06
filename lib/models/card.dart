import 'package:hive/hive.dart';

part 'card.g.dart';

@HiveType(typeId: 2)
class VirtualCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String cardNumber;

  @HiveField(3)
  String cardHolder;

  @HiveField(4)
  String expiryDate;

  @HiveField(5)
  String cvv;

  @HiveField(6)
  String pin;

  @HiveField(7)
  String type; // 'visa', 'mastercard'

  @HiveField(8)
  String status; // 'active', 'frozen', 'blocked'

  @HiveField(9)
  double spendingLimit;

  @HiveField(10)
  double currentSpending;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  String cardColor; // hex color for UI

  VirtualCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.pin,
    this.type = 'visa',
    this.status = 'active',
    this.spendingLimit = 5000.0,
    this.currentSpending = 0.0,
    DateTime? createdAt,
    this.cardColor = '#6366f1',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'pin': pin,
      'type': type,
      'status': status,
      'spendingLimit': spendingLimit,
      'currentSpending': currentSpending,
      'createdAt': createdAt.toIso8601String(),
      'cardColor': cardColor,
    };
  }

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      cardHolder: json['cardHolder'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cvv: json['cvv'] ?? '',
      pin: json['pin'] ?? '',
      type: json['type'] ?? 'visa',
      status: json['status'] ?? 'active',
      spendingLimit: (json['spendingLimit'] ?? 5000).toDouble(),
      currentSpending: (json['currentSpending'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      cardColor: json['cardColor'] ?? '#6366f1',
    );
  }

  bool get isActive => status == 'active';
  bool get isFrozen => status == 'frozen';
  bool get isBlocked => status == 'blocked';

  String get maskedNumber {
    if (cardNumber.length < 16) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  String get formattedNumber {
    if (cardNumber.length < 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} ${cardNumber.substring(4, 8)} ${cardNumber.substring(8, 12)} ${cardNumber.substring(12)}';
  }
}

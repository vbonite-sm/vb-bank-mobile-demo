import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String type; // 'transfer', 'deposit', 'withdrawal', 'bill_payment', 'topup', 'loan'

  @HiveField(3)
  double amount;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String status; // 'completed', 'pending', 'failed'

  @HiveField(7)
  String? recipientId;

  @HiveField(8)
  String? recipientName;

  @HiveField(9)
  String? recipientAccount;

  @HiveField(10)
  String? senderId;

  @HiveField(11)
  String? senderName;

  @HiveField(12)
  String? senderAccount;

  @HiveField(13)
  String? category; // 'electric', 'water', 'internet', etc.

  @HiveField(14)
  String? reference;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    DateTime? date,
    this.status = 'completed',
    this.recipientId,
    this.recipientName,
    this.recipientAccount,
    this.senderId,
    this.senderName,
    this.senderAccount,
    this.category,
    this.reference,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientAccount': recipientAccount,
      'senderId': senderId,
      'senderName': senderName,
      'senderAccount': senderAccount,
      'category': category,
      'reference': reference,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'completed',
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      recipientAccount: json['recipientAccount'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAccount: json['senderAccount'],
      category: json['category'],
      reference: json['reference'],
    );
  }

  bool get isCredit =>
      type == 'deposit' || type == 'topup' || (type == 'transfer' && senderId != userId);

  bool get isDebit =>
      type == 'withdrawal' ||
      type == 'bill_payment' ||
      (type == 'transfer' && senderId == userId);
}

import 'package:hive/hive.dart';

part 'bill_payment.g.dart';

@HiveType(typeId: 4)
class BillPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String providerId;

  @HiveField(3)
  String providerName;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String accountNumber;

  @HiveField(6)
  String status; // 'completed', 'pending', 'failed'

  @HiveField(7)
  DateTime paymentDate;

  @HiveField(8)
  String? reference;

  BillPayment({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.amount,
    required this.accountNumber,
    this.status = 'completed',
    DateTime? paymentDate,
    this.reference,
  }) : paymentDate = paymentDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'amount': amount,
      'accountNumber': accountNumber,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      'reference': reference,
    };
  }

  factory BillPayment.fromJson(Map<String, dynamic> json) {
    return BillPayment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      accountNumber: json['accountNumber'] ?? '',
      status: json['status'] ?? 'completed',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      reference: json['reference'],
    );
  }
}

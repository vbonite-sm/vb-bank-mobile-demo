import 'package:hive/hive.dart';

part 'loan.g.dart';

@HiveType(typeId: 3)
class Loan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String loanType; // 'personal', 'auto', 'home', 'education'

  @HiveField(3)
  double amount;

  @HiveField(4)
  int termMonths;

  @HiveField(5)
  double interestRate;

  @HiveField(6)
  double monthlyPayment;

  @HiveField(7)
  String status; // 'pending', 'approved', 'rejected', 'active', 'paid'

  @HiveField(8)
  DateTime applicationDate;

  @HiveField(9)
  DateTime? approvalDate;

  @HiveField(10)
  String? purpose;

  @HiveField(11)
  double totalRepayment;

  Loan({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.amount,
    required this.termMonths,
    required this.interestRate,
    required this.monthlyPayment,
    this.status = 'pending',
    DateTime? applicationDate,
    this.approvalDate,
    this.purpose,
    required this.totalRepayment,
  }) : applicationDate = applicationDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'loanType': loanType,
      'amount': amount,
      'termMonths': termMonths,
      'interestRate': interestRate,
      'monthlyPayment': monthlyPayment,
      'status': status,
      'applicationDate': applicationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'purpose': purpose,
      'totalRepayment': totalRepayment,
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      loanType: json['loanType'] ?? 'personal',
      amount: (json['amount'] ?? 0).toDouble(),
      termMonths: json['termMonths'] ?? 12,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      monthlyPayment: (json['monthlyPayment'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      applicationDate: json['applicationDate'] != null
          ? DateTime.parse(json['applicationDate'])
          : DateTime.now(),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      purpose: json['purpose'],
      totalRepayment: (json['totalRepayment'] ?? 0).toDouble(),
    );
  }

  /// Calculate monthly payment using amortization formula
  static double calculateMonthlyPayment(
      double principal, double annualRate, int months) {
    if (annualRate == 0) return principal / months;
    final monthlyRate = annualRate / 100 / 12;
    final factor =
        (monthlyRate * _pow(1 + monthlyRate, months)) /
        (_pow(1 + monthlyRate, months) - 1);
    return principal * factor;
  }

  static double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Alias: the loan type field
  String get type => loanType;

  /// Total repayment amount
  double get totalAmount => totalRepayment;

  /// Estimated remaining balance (simplified)
  double get remainingBalance => totalRepayment;

  String get loanTypeName {
    switch (loanType) {
      case 'personal':
        return 'Personal Loan';
      case 'auto':
        return 'Auto Loan';
      case 'home':
        return 'Home Loan';
      case 'education':
        return 'Education Loan';
      default:
        return loanType;
    }
  }
}

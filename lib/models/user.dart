import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  String email;

  @HiveField(4)
  String fullName;

  @HiveField(5)
  String role;

  @HiveField(6)
  String accountNumber;

  @HiveField(7)
  double balance;

  @HiveField(8)
  String currency;

  @HiveField(9)
  Map<String, double> crypto;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  String? phone;

  @HiveField(12)
  String? address;

  @HiveField(13)
  bool biometricEnabled;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    this.role = 'user',
    required this.accountNumber,
    this.balance = 0.0,
    this.currency = 'USD',
    Map<String, double>? crypto,
    DateTime? createdAt,
    this.phone,
    this.address,
    this.biometricEnabled = false,
  })  : crypto = crypto ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'fullName': fullName,
      'role': role,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'crypto': crypto,
      'createdAt': createdAt.toIso8601String(),
      'phone': phone,
      'address': address,
      'biometricEnabled': biometricEnabled,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      accountNumber: json['accountNumber'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      crypto: json['crypto'] != null
          ? Map<String, double>.from(
              (json['crypto'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              ),
            )
          : {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      phone: json['phone'],
      address: json['address'],
      biometricEnabled: json['biometricEnabled'] ?? false,
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? fullName,
    String? role,
    String? accountNumber,
    double? balance,
    String? currency,
    Map<String, double>? crypto,
    DateTime? createdAt,
    String? phone,
    String? address,
    bool? biometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      crypto: crypto ?? Map.from(this.crypto),
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

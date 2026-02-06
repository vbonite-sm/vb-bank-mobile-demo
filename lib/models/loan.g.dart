// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 3;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Loan(
      id: fields[0] as String,
      userId: fields[1] as String,
      loanType: fields[2] as String,
      amount: fields[3] as double,
      termMonths: fields[4] as int,
      interestRate: fields[5] as double,
      monthlyPayment: fields[6] as double,
      status: fields[7] as String,
      applicationDate: fields[8] as DateTime,
      approvalDate: fields[9] as DateTime?,
      purpose: fields[10] as String?,
      totalRepayment: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.loanType)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.termMonths)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.monthlyPayment)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.applicationDate)
      ..writeByte(9)
      ..write(obj.approvalDate)
      ..writeByte(10)
      ..write(obj.purpose)
      ..writeByte(11)
      ..write(obj.totalRepayment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

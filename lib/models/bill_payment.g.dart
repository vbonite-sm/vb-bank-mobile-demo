// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillPaymentAdapter extends TypeAdapter<BillPayment> {
  @override
  final int typeId = 4;

  @override
  BillPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return BillPayment(
      id: fields[0] as String,
      userId: fields[1] as String,
      providerId: fields[2] as String,
      providerName: fields[3] as String,
      amount: fields[4] as double,
      accountNumber: fields[5] as String,
      status: fields[6] as String,
      paymentDate: fields[7] as DateTime,
      reference: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BillPayment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.providerId)
      ..writeByte(3)
      ..write(obj.providerName)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.accountNumber)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.paymentDate)
      ..writeByte(8)
      ..write(obj.reference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

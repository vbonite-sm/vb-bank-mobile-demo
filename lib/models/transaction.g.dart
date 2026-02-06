// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Transaction(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      amount: fields[3] as double,
      description: fields[4] as String,
      date: fields[5] as DateTime,
      status: fields[6] as String,
      recipientId: fields[7] as String?,
      recipientName: fields[8] as String?,
      recipientAccount: fields[9] as String?,
      senderId: fields[10] as String?,
      senderName: fields[11] as String?,
      senderAccount: fields[12] as String?,
      category: fields[13] as String?,
      reference: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.recipientId)
      ..writeByte(8)
      ..write(obj.recipientName)
      ..writeByte(9)
      ..write(obj.recipientAccount)
      ..writeByte(10)
      ..write(obj.senderId)
      ..writeByte(11)
      ..write(obj.senderName)
      ..writeByte(12)
      ..write(obj.senderAccount)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.reference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

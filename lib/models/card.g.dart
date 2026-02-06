// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VirtualCardAdapter extends TypeAdapter<VirtualCard> {
  @override
  final int typeId = 2;

  @override
  VirtualCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return VirtualCard(
      id: fields[0] as String,
      userId: fields[1] as String,
      cardNumber: fields[2] as String,
      cardHolder: fields[3] as String,
      expiryDate: fields[4] as String,
      cvv: fields[5] as String,
      pin: fields[6] as String,
      type: fields[7] as String,
      status: fields[8] as String,
      spendingLimit: fields[9] as double,
      currentSpending: fields[10] as double,
      createdAt: fields[11] as DateTime,
      cardColor: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VirtualCard obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.cardNumber)
      ..writeByte(3)
      ..write(obj.cardHolder)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.cvv)
      ..writeByte(6)
      ..write(obj.pin)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.spendingLimit)
      ..writeByte(10)
      ..write(obj.currentSpending)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.cardColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

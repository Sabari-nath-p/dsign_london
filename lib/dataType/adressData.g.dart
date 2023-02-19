// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adressData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class addressDataAdapter extends TypeAdapter<addressData> {
  @override
  final int typeId = 2;

  @override
  addressData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return addressData(
      address: fields[0] as String,
      city: fields[3] as String,
      country: fields[1] as String,
      details: fields[5] as String,
      state: fields[2] as String,
      zip: fields[4] as String,
      title: fields[6] as String,
      id: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, addressData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.zip)
      ..writeByte(5)
      ..write(obj.details)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is addressDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

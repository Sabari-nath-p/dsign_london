// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class userDataAdapter extends TypeAdapter<userData> {
  @override
  final int typeId = 3;

  @override
  userData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return userData(
      name: fields[1] as String,
      email: fields[2] as String,
      id: fields[0] as int,
      phone: fields[3] as String,
      address: (fields[5] as List).cast<addressData>(),
      profileUrl: fields[4] as String,
      availablePoint: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, userData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profileUrl)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.availablePoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is userDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

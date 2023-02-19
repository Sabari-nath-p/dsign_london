// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class productDataAdapter extends TypeAdapter<productData> {
  @override
  final int typeId = 1;

  @override
  productData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return productData(
      id: fields[0] as int,
      name: fields[1] as String,
      price: fields[3] as int,
      quantity: fields[4] as int,
      slug: fields[2] as String,
      subTotal: fields[5] as int,
      save: fields[6] as int,
      image: fields[7] as String,
      unit: fields[8] as String,
    )..vid = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, productData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.subTotal)
      ..writeByte(6)
      ..write(obj.save)
      ..writeByte(7)
      ..write(obj.image)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.vid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is productDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

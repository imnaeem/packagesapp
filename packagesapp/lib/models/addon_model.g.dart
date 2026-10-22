// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddonModelAdapter extends TypeAdapter<AddonModel> {
  @override
  final int typeId = 2;

  @override
  AddonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddonModel(
      name: fields[0] as String,
      value: fields[1] as String,
      unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddonModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

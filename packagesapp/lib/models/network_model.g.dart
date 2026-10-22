// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetworkModelAdapter extends TypeAdapter<NetworkModel> {
  @override
  final int typeId = 0;

  @override
  NetworkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworkModel(
      id: fields[0] as String,
      name: fields[1] as String,
      slug: fields[2] as String,
      slogan: fields[3] as String,
      logoUrl: fields[4] as String,
      brandColor: fields[5] as String,
      isActive: fields[6] as bool,
      packageCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NetworkModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.slogan)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.brandColor)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.packageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

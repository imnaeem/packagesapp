// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceModelAdapter extends TypeAdapter<ResourceModel> {
  @override
  final int typeId = 1;

  @override
  ResourceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResourceModel(
      onNetMinutes: fields[0] as int?,
      offNetMinutes: fields[1] as int?,
      sms: fields[2] as int?,
      dataMb: fields[3] as int?,
      dataGb: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ResourceModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.onNetMinutes)
      ..writeByte(1)
      ..write(obj.offNetMinutes)
      ..writeByte(2)
      ..write(obj.sms)
      ..writeByte(3)
      ..write(obj.dataMb)
      ..writeByte(4)
      ..write(obj.dataGb);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

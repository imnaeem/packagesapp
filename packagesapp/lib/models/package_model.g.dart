// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PackageModelAdapter extends TypeAdapter<PackageModel> {
  @override
  final int typeId = 3;

  @override
  PackageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackageModel(
      id: fields[0] as String,
      networkId: fields[1] as String,
      name: fields[2] as String,
      category: fields[3] as String,
      subCategory: fields[4] as String,
      price: fields[5] as double,
      validityDays: fields[6] as int,
      activationCode: fields[7] as String,
      deactivationCode: fields[8] as String,
      resources: fields[9] as ResourceModel,
      addons: (fields[10] as List?)?.cast<AddonModel>() ?? [],
      extraServices: (fields[11] as List?)?.cast<String>() ?? [],
      details: fields[12] as String? ?? '',
      tags: (fields[13] as List?)?.cast<String>() ?? [],
      isActive: fields[14] as bool? ?? true,
      isFeatured: fields[15] as bool? ?? false,
      createdAt: fields[16] as String? ?? '',
      updatedAt: fields[17] as String? ?? '',
      rechargeRequired: fields[18] as double?,
      allNetMinutes: fields[19] as int?,
      socialApps: (fields[20] as List?)?.cast<String>() ?? const [],
      dataTimeWindow: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PackageModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.networkId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.subCategory)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.validityDays)
      ..writeByte(7)
      ..write(obj.activationCode)
      ..writeByte(8)
      ..write(obj.deactivationCode)
      ..writeByte(9)
      ..write(obj.resources)
      ..writeByte(10)
      ..write(obj.addons)
      ..writeByte(11)
      ..write(obj.extraServices)
      ..writeByte(12)
      ..write(obj.details)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.isFeatured)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.rechargeRequired)
      ..writeByte(19)
      ..write(obj.allNetMinutes)
      ..writeByte(20)
      ..write(obj.socialApps)
      ..writeByte(21)
      ..write(obj.dataTimeWindow);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive/hive.dart';

part 'addon_model.g.dart';

@HiveType(typeId: 2)
class AddonModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final String unit;

  AddonModel({
    required this.name,
    required this.value,
    required this.unit,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
      };

  String get displayLabel => '$name: $value $unit'.trim();
}

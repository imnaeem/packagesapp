import 'package:hive/hive.dart';

part 'favourite_model.g.dart';

@HiveType(typeId: 4)
class FavouriteModel extends HiveObject {
  @HiveField(0)
  final String packageId;

  @HiveField(1)
  final String networkId;

  @HiveField(2)
  final String addedAt;

  FavouriteModel({
    required this.packageId,
    required this.networkId,
    required this.addedAt,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      packageId: json['packageId'] as String? ?? '',
      networkId: json['networkId'] as String? ?? '',
      addedAt: json['addedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'packageId': packageId,
        'networkId': networkId,
        'addedAt': addedAt,
      };
}

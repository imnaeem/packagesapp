import 'package:hive/hive.dart';

part 'network_model.g.dart';

@HiveType(typeId: 0)
class NetworkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final String slogan;

  @HiveField(4)
  final String logoUrl;

  @HiveField(5)
  final String brandColor;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final int packageCount;

  NetworkModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.slogan,
    required this.logoUrl,
    required this.brandColor,
    required this.isActive,
    this.packageCount = 0,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      slogan: json['slogan'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      brandColor: json['brandColor'] as String? ?? '#000000',
      isActive: json['isActive'] as bool? ?? true,
      packageCount: json['packageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'slogan': slogan,
        'logoUrl': logoUrl,
        'brandColor': brandColor,
        'isActive': isActive,
        'packageCount': packageCount,
      };
}

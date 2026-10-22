import 'package:hive/hive.dart';
import 'resource_model.dart';
import 'addon_model.dart';

part 'package_model.g.dart';

@HiveType(typeId: 3)
class PackageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String networkId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String subCategory;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final int validityDays;

  @HiveField(7)
  final String activationCode;

  @HiveField(8)
  final String deactivationCode;

  @HiveField(9)
  final ResourceModel resources;

  @HiveField(10)
  final List<AddonModel> addons;

  @HiveField(11)
  final List<String> extraServices;

  @HiveField(12)
  final String details;

  @HiveField(13)
  final List<String> tags;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final bool isFeatured;

  @HiveField(16)
  final String createdAt;

  @HiveField(17)
  final String updatedAt;

  @HiveField(18)
  final double? rechargeRequired;

  @HiveField(19)
  final int? allNetMinutes;

  @HiveField(20)
  final List<String> socialApps;

  @HiveField(21)
  final String? dataTimeWindow;

  PackageModel({
    required this.id,
    required this.networkId,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.validityDays,
    required this.activationCode,
    required this.deactivationCode,
    required this.resources,
    required this.addons,
    required this.extraServices,
    required this.details,
    required this.tags,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.rechargeRequired,
    this.allNetMinutes,
    this.socialApps = const [],
    this.dataTimeWindow,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String? ?? '',
      networkId: json['networkId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'hybrid',
      subCategory: json['subCategory'] as String? ?? 'monthly',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      validityDays: json['validityDays'] as int? ?? 0,
      activationCode: json['activationCode'] as String? ?? '',
      deactivationCode: json['deactivationCode'] as String? ?? '',
      resources: json['resources'] != null
          ? ResourceModel.fromJson(json['resources'] as Map<String, dynamic>)
          : ResourceModel(),
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => AddonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      extraServices: (json['extraServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      details: json['details'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      rechargeRequired: (json['rechargeRequired'] as num?)?.toDouble() ??
          (json['loadRequired'] as num?)?.toDouble(),
      allNetMinutes: json['allNetMinutes'] as int?,
      socialApps: (json['socialApps'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          const [],
      dataTimeWindow: json['dataTimeWindow'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'networkId': networkId,
        'name': name,
        'category': category,
        'subCategory': subCategory,
        'price': price,
        'validityDays': validityDays,
        'activationCode': activationCode,
        'deactivationCode': deactivationCode,
        'resources': resources.toJson(),
        'addons': addons.map((a) => a.toJson()).toList(),
        'extraServices': extraServices,
        'details': details,
        'tags': tags,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        if (rechargeRequired != null) 'rechargeRequired': rechargeRequired,
        if (allNetMinutes != null) 'allNetMinutes': allNetMinutes,
        if (socialApps.isNotEmpty) 'socialApps': socialApps,
        if (dataTimeWindow != null) 'dataTimeWindow': dataTimeWindow,
      };

  String get validityDisplay {
    if (validityDays == 1) return '1 Day';
    if (validityDays == 7) return '1 Week';
    if (validityDays == 30) return '30 Days';
    if (validityDays == 365) return '1 Year';
    return '$validityDays Days';
  }

  bool get isPopular =>
      tags.any((t) => const ['popular', 'bestseller', 'trending'].contains(t.toLowerCase()));

  bool get isSpecialOffer =>
      tags.any((t) {
        final lower = t.toLowerCase();
        return lower.contains('special') ||
            lower.contains('offer') ||
            const ['best-value', 'supercard', 'flagship', 'grand', 'best'].contains(lower);
      });

  String get priceDisplay {
    if (price <= 0.0) return 'Free';
    return 'Rs. ${price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2)}';
  }
}

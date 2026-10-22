import 'package:hive/hive.dart';

part 'resource_model.g.dart';

@HiveType(typeId: 1)
class ResourceModel extends HiveObject {
  @HiveField(0)
  final int? onNetMinutes;

  @HiveField(1)
  final int? offNetMinutes;

  @HiveField(2)
  final int? sms;

  @HiveField(3)
  final int? dataMb;

  @HiveField(4)
  final double? dataGb;

  ResourceModel({
    this.onNetMinutes,
    this.offNetMinutes,
    this.sms,
    this.dataMb,
    this.dataGb,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      onNetMinutes: json['onNetMinutes'] as int?,
      offNetMinutes: json['offNetMinutes'] as int?,
      sms: json['sms'] as int?,
      dataMb: json['dataMb'] as int?,
      dataGb: (json['dataGb'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (onNetMinutes != null) 'onNetMinutes': onNetMinutes,
        if (offNetMinutes != null) 'offNetMinutes': offNetMinutes,
        if (sms != null) 'sms': sms,
        if (dataMb != null) 'dataMb': dataMb,
        if (dataGb != null) 'dataGb': dataGb,
      };

  String get dataDisplay {
    if (dataGb != null && dataGb! > 0) return '${dataGb!.toStringAsFixed(dataGb! == dataGb!.roundToDouble() ? 0 : 1)} GB';
    if (dataMb != null && dataMb! > 0) return '$dataMb MB';
    return '—';
  }

  String get callDisplay {
    final parts = <String>[];
    if (onNetMinutes != null && onNetMinutes! > 0) parts.add('$onNetMinutes On-Net');
    if (offNetMinutes != null && offNetMinutes! > 0) parts.add('$offNetMinutes Off-Net');
    return parts.isEmpty ? '—' : '${parts.join(', ')} Mins';
  }

  String get smsDisplay {
    if (sms != null && sms! > 0) return '$sms SMS';
    return '—';
  }
}

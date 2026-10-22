import 'package:flutter/material.dart';

class NetworkInfo {
  final String id;
  final String name;
  final String slug;
  final String slogan;
  final String logoAsset;
  final Color brandColor;
  final Color brandColorDark;

  const NetworkInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.slogan,
    required this.logoAsset,
    required this.brandColor,
    required this.brandColorDark,
  });
}

class NetworkConstants {
  NetworkConstants._();

  static const List<NetworkInfo> networks = [
    NetworkInfo(
      id: 'jazz',
      name: 'Jazz',
      slug: 'jazz',
      slogan: 'Pakistan Ka Dil',
      logoAsset: 'assets/images/jazz.png',
      brandColor: Color(0xFFE31837),
      brandColorDark: Color(0xFFB01229),
    ),
    NetworkInfo(
      id: 'zong',
      name: 'Zong',
      slug: 'zong',
      slogan: 'First in 4G',
      logoAsset: 'assets/images/zong.png',
      brandColor: Color(0xFF8DC63F),
      brandColorDark: Color(0xFF6A9A2E),
    ),
    NetworkInfo(
      id: 'telenor',
      name: 'Telenor',
      slug: 'telenor',
      slogan: 'Skandinavian Spirit',
      logoAsset: 'assets/images/telenor.png',
      brandColor: Color(0xFF00A0E3),
      brandColorDark: Color(0xFF0078AC),
    ),
    NetworkInfo(
      id: 'ufone',
      name: 'Ufone',
      slug: 'ufone',
      slogan: 'Tum Hi Toh Ho',
      logoAsset: 'assets/images/ufone.png',
      brandColor: Color(0xFFEF7A15),
      brandColorDark: Color(0xFFBF5E0A),
    ),
    NetworkInfo(
      id: 'ptcl',
      name: 'PTCL',
      slug: 'ptcl',
      slogan: 'It\'s All About You',
      logoAsset: 'assets/images/pta.png',
      brandColor: Color(0xFF003087),
      brandColorDark: Color(0xFF002060),
    ),
  ];

  static const String categoryFree = 'free';

  static NetworkInfo? findById(String id) {
    try {
      return networks.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}

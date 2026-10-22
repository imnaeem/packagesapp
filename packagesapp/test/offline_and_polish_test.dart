import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagesapp/core/theme/app_colors.dart';
import 'package:packagesapp/models/package_model.dart';
import 'package:packagesapp/models/resource_model.dart';
import 'package:packagesapp/models/network_model.dart';

void main() {
  group('Offline Bundled Seed Data Tests', () {
    test('bundled_packages.json contains valid data for all 5 networks', () {
      final file = File('assets/data/bundled_packages.json');
      expect(file.existsSync(), isTrue, reason: 'bundled_packages.json must exist');

      final content = file.readAsStringSync();
      final decoded = jsonDecode(content) as Map<String, dynamic>;

      expect(decoded.containsKey('packages'), isTrue);
      expect(decoded.containsKey('networks'), isTrue);

      final networks = (decoded['networks'] as List)
          .map((e) => NetworkModel.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(networks.length, equals(5));
      final networkIds = networks.map((n) => n.id).toSet();
      expect(networkIds, containsAll(['jazz', 'zong', 'telenor', 'ufone', 'ptcl']));

      final packages = (decoded['packages'] as List)
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(packages.length, greaterThanOrEqualTo(30));

      final packageNetworks = packages.map((p) => p.networkId).toSet();
      expect(packageNetworks, containsAll(['jazz', 'zong', 'telenor', 'ufone', 'ptcl']));

      // Check categories
      final categories = packages.map((p) => p.category).toSet();
      expect(categories, containsAll(['call', 'internet', 'hybrid', 'social']));

      // Check dynamic fields
      final withLoad = packages.where((p) => p.rechargeRequired != null && p.rechargeRequired! > 0);
      expect(withLoad, isNotEmpty);

      final withSocial = packages.where((p) => p.socialApps.isNotEmpty);
      expect(withSocial, isNotEmpty);

      final withWindow = packages.where((p) => p.dataTimeWindow != null && p.dataTimeWindow!.isNotEmpty);
      expect(withWindow, isNotEmpty);
    });

    test('PackageModel parses and serializes dynamic fields safely', () {
      final json = {
        'id': 'test_pkg',
        'networkId': 'jazz',
        'name': 'Test Package',
        'category': 'social',
        'subCategory': 'weekly',
        'price': 250.0,
        'rechargeRequired': 300.0,
        'validityDays': 7,
        'activationCode': '*123#',
        'deactivationCode': '*123*4#',
        'resources': {
          'dataGb': 5.0,
          'onNetMinutes': 200,
        },
        'socialApps': ['WhatsApp', 'YOUTUBE'],
        'dataTimeWindow': '2 AM - 2 PM',
        'allNetMinutes': 50,
      };

      final pkg = PackageModel.fromJson(json);
      expect(pkg.id, equals('test_pkg'));
      expect(pkg.price, equals(250.0));
      expect(pkg.rechargeRequired, equals(300.0));
      expect(pkg.socialApps, equals(['whatsapp', 'youtube']));
      expect(pkg.dataTimeWindow, equals('2 AM - 2 PM'));
      expect(pkg.allNetMinutes, equals(50));

      final serialized = pkg.toJson();
      expect(serialized['rechargeRequired'], equals(300.0));
      expect(serialized['socialApps'], equals(['whatsapp', 'youtube']));
      expect(serialized['dataTimeWindow'], equals('2 AM - 2 PM'));
      expect(serialized['allNetMinutes'], equals(50));
    });

    test('USSD Dial encoding preserves # characters', () {
      const code = '*123*4#';
      final uri = Uri.parse('tel:${Uri.encodeComponent(code)}');
      expect(uri.toString(), equals('tel:*123*4%23'));
    });

    test('PackageModel isPopular and isSpecialOffer getters detect tags correctly', () {
      final popularPkg = PackageModel(
        id: 'p1',
        networkId: 'jazz',
        name: 'Weekly Super',
        category: 'hybrid',
        subCategory: 'weekly',
        price: 350,
        validityDays: 7,
        activationCode: '*117*7#',
        deactivationCode: '*117*7*4#',
        resources: ResourceModel(),
        addons: [],
        extraServices: [],
        details: '',
        tags: ['popular', 'weekly'],
        isActive: true,
        isFeatured: false,
        createdAt: '',
        updatedAt: '',
      );

      final specialPkg = PackageModel(
        id: 'p2',
        networkId: 'zong',
        name: 'Super Card',
        category: 'hybrid',
        subCategory: 'monthly',
        price: 1190,
        validityDays: 30,
        activationCode: '*6464#',
        deactivationCode: '',
        resources: ResourceModel(),
        addons: [],
        extraServices: [],
        details: '',
        tags: ['supercard', 'best-value'],
        isActive: true,
        isFeatured: false,
        createdAt: '',
        updatedAt: '',
      );

      expect(popularPkg.isPopular, isTrue);
      expect(popularPkg.isSpecialOffer, isFalse);

      expect(specialPkg.isPopular, isFalse);
      expect(specialPkg.isSpecialOffer, isTrue);
    });

    test('AppAccentColor enum correctly maps colors and defaults', () {
      expect(AppAccentColor.values.length, equals(5));
      expect(AppAccentColor.fromId('teal'), equals(AppAccentColor.teal));
      expect(AppAccentColor.fromId('indigo'), equals(AppAccentColor.indigo));
      expect(AppAccentColor.fromId('emerald'), equals(AppAccentColor.emerald));
      expect(AppAccentColor.fromId('purple'), equals(AppAccentColor.purple));
      expect(AppAccentColor.fromId('orange'), equals(AppAccentColor.orange));
      expect(AppAccentColor.fromId('unknown'), equals(AppAccentColor.teal));
    });
  });
}

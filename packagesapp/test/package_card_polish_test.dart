import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagesapp/core/providers/providers.dart';
import 'package:packagesapp/data/repositories/favourite_repository.dart';
import 'package:packagesapp/features/packages/widgets/package_card.dart';
import 'package:packagesapp/models/favourite_model.dart';
import 'package:packagesapp/models/package_model.dart';
import 'package:packagesapp/models/resource_model.dart';

class MockFavouriteRepository extends FavouriteRepository {
  @override
  List<FavouriteModel> getFavourites() => [];

  @override
  bool isFavourite(String packageId) => false;
}

void main() {
  testWidgets('PackageCard renders 4-digit price, long USSD codes, and share icon without overflow', (tester) async {
    final pkg = PackageModel(
      id: 'jazz_super_1190',
      networkId: 'jazz',
      name: 'Jazz Super Monthly Max 100GB Long Title Extra',
      category: 'hybrid',
      subCategory: 'monthly',
      price: 1190.0,
      rechargeRequired: 1300.0,
      validityDays: 30,
      activationCode: '*117*30*4#',
      deactivationCode: '*117*30*4*4#',
      resources: ResourceModel(
        dataGb: 100.0,
        onNetMinutes: 5000,
        offNetMinutes: 500,
        sms: 5000,
      ),
      addons: [],
      extraServices: ['Tamasha MBs', 'YouTube'],
      details: 'Super max monthly bundle',
      tags: ['popular', 'best-value'],
      isActive: true,
      isFeatured: true,
      createdAt: '',
      updatedAt: '',
    );

    // Test on a narrow screen (340x700) to ensure strict overflow prevention
    tester.view.physicalSize = const Size(340, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favouriteRepositoryProvider.overrideWithValue(MockFavouriteRepository()),
          bestValueIdsProvider('jazz').overrideWithValue({}),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: PackageCard(
                  package: pkg,
                  networkColor: const Color(0xFFE31837),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 4-digit price text is present
    expect(find.text('1190'), findsOneWidget);

    // Verify activate and deactivate code buttons are present
    expect(find.text('*117*30*4#'), findsOneWidget);
    expect(find.text('*117*30*4*4#'), findsOneWidget);

    // Verify Share icon button is rendered in the header
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);

    // Verify no RenderFlex overflow occurred
    expect(tester.takeException(), isNull);
  });
}

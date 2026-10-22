import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagesapp/core/constants/app_constants.dart';
import 'package:packagesapp/core/constants/network_constants.dart';
import 'package:packagesapp/core/providers/providers.dart';
import 'package:packagesapp/core/utils/app_utils.dart';
import 'package:packagesapp/features/blog/blog_detail_page.dart';
import 'package:packagesapp/features/blog/blog_list_page.dart';
import 'package:packagesapp/features/blog/blog_post_model.dart';
import 'package:packagesapp/features/blog/blog_repository.dart';
import 'package:packagesapp/features/home/widgets/featured_carousel.dart';
import 'package:packagesapp/models/package_model.dart';
import 'package:packagesapp/models/resource_model.dart';

class FakeBlogRepository extends BlogRepository {
  final List<BlogPostModel> posts;
  FakeBlogRepository(this.posts);

  @override
  Future<List<BlogPostModel>> getPosts({bool forceRefresh = false}) async => posts;
}

void main() {
  group('Feature 1: Featured Carousel Tests', () {
    testWidgets('FeaturedCarousel renders layered cards and dot indicators',
        (tester) async {
      final samplePackages = [
        PackageModel(
          id: 'test_pkg_1',
          networkId: 'jazz',
          name: 'Jazz Super 4G Monthly',
          category: 'internet',
          subCategory: 'monthly',
          price: 999.0,
          validityDays: 30,
          activationCode: '*117*30#',
          deactivationCode: '*117*30*4#',
          resources: ResourceModel(dataGb: 30.0, onNetMinutes: 1000),
          addons: [],
          extraServices: [],
          details: 'Sample super package',
          tags: ['featured', 'monthly'],
          isActive: true,
          isFeatured: true,
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
        ),
        PackageModel(
          id: 'test_pkg_2',
          networkId: 'zong',
          name: 'Zong Monthly Pro Max',
          category: 'hybrid',
          subCategory: 'monthly',
          price: 1300.0,
          validityDays: 30,
          activationCode: '*6464#',
          deactivationCode: '',
          resources: ResourceModel(
              dataGb: 60.0, onNetMinutes: 5000, offNetMinutes: 500),
          addons: [],
          extraServices: [],
          details: 'Zong Pro package',
          tags: ['featured'],
          isActive: true,
          isFeatured: true,
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            featuredPackagesProvider.overrideWithValue(samplePackages),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FeaturedCarousel(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Top & Featured Packages'), findsOneWidget);
      expect(find.text('Best Value'), findsOneWidget);

      // Check carousel elements
      expect(find.byType(PageView), findsOneWidget);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      final controller = pageView.controller;
      expect(controller?.viewportFraction, equals(0.88));

      // Check card details
      expect(find.text('Activate'), findsWidgets);
      expect(find.text('Jazz Super 4G Monthly'), findsOneWidget);
    });
  });

  group('Feature 2: Free Tricks & Offers Tests', () {
    test('AppConstants and AppUtils support free category', () {
      expect(AppConstants.packageCategories, contains('free'));
      expect(AppUtils.categoryLabel('free'), equals('Free Offers'));
      expect(AppUtils.categoryIcon('free'), equals(Icons.card_giftcard_rounded));
      expect(NetworkConstants.categoryFree, equals('free'));
    });

    test('bundled_packages.json has free offers with price: 0.0', () {
      final file = File('assets/data/bundled_packages.json');
      expect(file.existsSync(), isTrue);

      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rawPackages = data['packages'] as List;
      final packages = rawPackages
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final freeOffers = packages.where((p) => p.category == 'free' && p.price == 0.0).toList();
      expect(freeOffers.length, greaterThanOrEqualTo(6));

      final freeNetworks = freeOffers.map((p) => p.networkId).toSet();
      expect(freeNetworks, containsAll(['jazz', 'zong', 'telenor', 'ufone']));

      // Test priceDisplay
      final freePkg = freeOffers.first;
      expect(freePkg.priceDisplay, equals('Free'));

      // Verify specific sample seed offers
      final simLagaoJazz = packages.firstWhere((p) => p.activationCode == '*5555#');
      expect(simLagaoJazz.name, contains('Free SIM Lagao'));
      expect(simLagaoJazz.price, equals(0.0));
    });
  });

  group('Feature 3: WordPress Blog Integration Tests', () {
    test('BlogPostModel correctly decodes WordPress REST API format', () {
      final wpJson = {
        'id': 101,
        'date': '2026-03-20T14:30:00',
        'link': 'https://techshiner.com/free-internet-guide-2026',
        'title': {'rendered': 'How to Get Free Internet &#8211; 100% Working Tips'},
        'excerpt': {'rendered': '<p>Here is an excerpt with <strong>HTML</strong> tags.</p>'},
        'content': {
          'rendered': '<h2>Introduction</h2><p>Full article content with useful steps.</p>'
        },
        '_embedded': {
          'author': [
            {'id': 1, 'name': 'Hamza Ali'}
          ],
          'wp:featuredmedia': [
            {'source_url': 'https://techshiner.com/uploads/banner.jpg'}
          ]
        }
      };

      final post = BlogPostModel.fromJson(wpJson);
      expect(post.id, equals('101'));
      expect(post.title, equals('How to Get Free Internet – 100% Working Tips'));
      expect(post.excerpt, equals('Here is an excerpt with HTML tags.'));
      expect(post.authorName, equals('Hamza Ali'));
      expect(post.featuredMediaUrl, equals('https://techshiner.com/uploads/banner.jpg'));
      expect(post.link, equals('https://techshiner.com/free-internet-guide-2026'));
      expect(post.readingTimeMinutes, greaterThanOrEqualTo(1));
    });

    test('BlogRepository provides graceful fallback articles', () async {
      final repo = BlogRepository();
      final fallbacks = await repo.getPosts();
      expect(fallbacks, isNotEmpty);
    });

    testWidgets('BlogListPage renders properly', (tester) async {
      final testPost = BlogPostModel(
        id: '1',
        title: 'Complete SIM Lagao Guide 2026',
        excerpt: 'Read how to reactivate your inactive SIM card.',
        content:
            '<h2>Step 1</h2><p>Insert your SIM.</p><ul><li>Dial *5555#</li></ul>',
        date: DateTime(2026, 3, 1),
        link: 'https://techshiner.com/guide',
        featuredMediaUrl: '',
        authorName: 'Tech Shiner Editor',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            blogRepositoryProvider
                .overrideWithValue(FakeBlogRepository([testPost])),
          ],
          child: const MaterialApp(
            home: BlogListPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Blog & Guides'), findsOneWidget);
      expect(find.text('Complete SIM Lagao Guide 2026'), findsOneWidget);
      expect(find.text('Tech Shiner Editor'), findsOneWidget);
    });

    testWidgets('BlogDetailPage renders properly', (tester) async {
      final testPost = BlogPostModel(
        id: '1',
        title: 'Complete SIM Lagao Guide 2026',
        excerpt: 'Read how to reactivate your inactive SIM card.',
        content:
            '<h2>Step 1</h2><p>Insert your SIM.</p><ul><li>Dial *5555#</li></ul>',
        date: DateTime(2026, 3, 1),
        link: 'https://techshiner.com/guide',
        featuredMediaUrl: '',
        authorName: 'Tech Shiner Editor',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlogDetailPage(
            postId: '1',
            post: testPost,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Complete SIM Lagao Guide 2026'), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Insert your SIM.'), findsOneWidget);
      expect(find.text('Dial *5555#'), findsOneWidget);
    });
  });
}

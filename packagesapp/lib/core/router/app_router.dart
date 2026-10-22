import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_page.dart';
import '../../features/packages/package_list_page.dart';
import '../../features/package_detail/package_detail_page.dart';
import '../../features/favourites/favourites_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/settings/about_page.dart';
import '../../features/settings/contact_page.dart';
import '../../features/settings/feedback_page.dart';
import '../../features/settings/privacy_policy_page.dart';
import '../../features/settings/terms_page.dart';
import '../../features/settings/profile_page.dart';
import '../../features/compare/compare_page.dart';
import '../../features/speedtest/speed_test_page.dart';
import '../../features/match_usage/match_usage_page.dart';
import '../../features/blog/blog_list_page.dart';
import '../../features/blog/blog_detail_page.dart';
import '../../features/blog/blog_post_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/packages/:networkId',
        name: 'packages',
        builder: (context, state) {
          final networkId = state.pathParameters['networkId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final networkName = extra?['name'] as String? ?? networkId;
          final initialCategory = extra?['category'] as String?;
          return PackageListPage(
            networkId: networkId,
            networkName: networkName,
            initialCategory: initialCategory,
          );
        },
      ),
      GoRoute(
        path: '/package/:id',
        name: 'packageDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PackageDetailPage(packageId: id);
        },
      ),
      GoRoute(
        path: '/favourites',
        name: 'favourites',
        builder: (context, state) => const FavouritesPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),
      GoRoute(
        path: '/compare',
        name: 'compare',
        builder: (context, state) => const ComparePage(),
      ),
      GoRoute(
        path: '/speedtest',
        name: 'speedtest',
        builder: (context, state) => const SpeedTestPage(),
      ),
      GoRoute(
        path: '/find-package',
        name: 'findPackage',
        builder: (context, state) => const MatchUsagePage(),
      ),
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) => const BlogListPage(),
      ),
      GoRoute(
        path: '/blog/:id',
        name: 'blogDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final post = state.extra as BlogPostModel?;
          return BlogDetailPage(postId: id, post: post);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

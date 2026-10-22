import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/hive_service.dart';
import 'blog_post_model.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository();
});

final blogPostsProvider = FutureProvider<List<BlogPostModel>>((ref) async {
  final repo = ref.watch(blogRepositoryProvider);
  return repo.getPosts();
});

class BlogRepository {
  static const String _wpApiUrl =
      'https://techshiner.com/wp-json/wp/v2/posts?_embed=true&per_page=10';
  static const String _cacheKey = 'techshiner_cached_posts';

  final Dio _dio;

  BlogRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 7),
                receiveTimeout: const Duration(seconds: 7),
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  'Accept': 'application/json',
                },
              ),
            );

  Future<List<BlogPostModel>> getPosts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _getCachedPosts();
      if (cached.isNotEmpty) {
        // Try fetching in background or return cached
        _fetchAndCacheSilently();
        return cached;
      }
    }

    try {
      final response = await _dio.get(_wpApiUrl);
      if (response.statusCode == 200 && response.data is List) {
        final rawList = response.data as List;
        final posts = rawList
            .map((item) =>
                BlogPostModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (posts.isNotEmpty) {
          await _saveCachedPosts(posts);
          return posts;
        }
      }
    } catch (e) {
      debugPrint('Blog fetch from techshiner.com failed: $e');
    }

    // Fallback: check Hive cache again
    final cached = _getCachedPosts();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Graceful fallback articles when site is unreachable
    final fallback = _getGracefulFallbackPosts();
    await _saveCachedPosts(fallback);
    return fallback;
  }

  Future<void> _fetchAndCacheSilently() async {
    try {
      final response = await _dio.get(_wpApiUrl);
      if (response.statusCode == 200 && response.data is List) {
        final rawList = response.data as List;
        final posts = rawList
            .map((item) =>
                BlogPostModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (posts.isNotEmpty) {
          await _saveCachedPosts(posts);
        }
      }
    } catch (_) {
      // Silently ignore background fetch failure
    }
  }

  List<BlogPostModel> _getCachedPosts() {
    try {
      if (!Hive.isBoxOpen(AppConstants.metaBox)) return [];
      final raw = HiveService.metaBox.get(_cacheKey);
      if (raw == null) return [];

      List<dynamic> list;
      if (raw is String) {
        list = jsonDecode(raw) as List;
      } else if (raw is List) {
        list = raw;
      } else {
        return [];
      }

      return list
          .map((item) =>
              BlogPostModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error reading cached blog posts: $e');
      return [];
    }
  }

  Future<void> _saveCachedPosts(List<BlogPostModel> posts) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.metaBox)) return;
      final list = posts.map((p) => p.toJson()).toList();
      await HiveService.metaBox.put(_cacheKey, list);
    } catch (e) {
      debugPrint('Error saving cached blog posts: $e');
    }
  }

  List<BlogPostModel> _getGracefulFallbackPosts() {
    return [
      BlogPostModel(
        id: 'ts_jazz_sim_lagao',
        title: 'Jazz SIM Lagao Offer 2026: Code & Free Data, Minutes Details',
        excerpt:
            'Discover how to reactivate your inactive Jazz SIM and receive 6 GB free 4G data, 3,000 on-net minutes, and 3,000 SMS for 60 days.',
        content: '''
<p>If you have a Jazz or Warid prepaid SIM card that has not been in use for the past 30 days or more, you are eligible for the official <strong>Jazz SIM Lagao Offer 2026</strong>.</p>
<h2>How to Activate</h2>
<p>To claim this complimentary offer, follow these quick steps:</p>
<ul>
  <li>Insert your inactive Jazz SIM into your mobile phone.</li>
  <li>Dial <strong>*5555#</strong> from your dialer.</li>
  <li>You will receive an instant confirmation SMS with your allocated bonus resources.</li>
</ul>
<h2>Incentives & Benefits</h2>
<p>Upon successful reactivation, Jazz grants you the following resources:</p>
<ul>
  <li><strong>6,000 MBs (6 GB) 4G Internet:</strong> Includes 3 GB for WhatsApp and Tamasha live TV streaming.</li>
  <li><strong>3,000 Jazz & Warid Minutes:</strong> Distributed as 50 minutes daily for 60 days.</li>
  <li><strong>3,000 SMS:</strong> Can be sent to all local networks across Pakistan.</li>
</ul>
<p>Note: This promotion is exclusively valid for prepaid subscribers with no commercial usage on the number during the last 30 consecutive days.</p>
''',
        date: DateTime.now().subtract(const Duration(days: 2)),
        link: 'https://techshiner.com/jazz-sim-lagao-offer-2026',
        featuredMediaUrl:
            'https://images.unsplash.com/photo-1512428559087-560fa5ceab42?auto=format&fit=crop&w=800&q=80',
        authorName: 'Tech Shiner Team',
      ),
      BlogPostModel(
        id: 'ts_zong_free_whatsapp',
        title: 'How to Get Free WhatsApp on Zong 4G: Zero Balance Guide',
        excerpt:
            'Step-by-step guide on activating Zong free monthly WhatsApp offer with zero balance deduction and 2 GB dedicated quota.',
        content: '''
<p>Zong 4G subscribers can access WhatsApp completely free without requiring an active balance or paid subscription. This guide walks you through activating Zong's free social service.</p>
<h2>Activation Method</h2>
<p>Dial <strong>*247#</strong> on your Zong prepaid number. Within a few moments, your complimentary 2,048 MB (2 GB) WhatsApp bucket will be activated for the entire month.</p>
<h2>What is Covered?</h2>
<ul>
  <li>Text chats and emoji sharing on WhatsApp</li>
  <li>Voice messaging and audio notes</li>
  <li>Photo and document transfers</li>
  <li>WhatsApp status updates</li>
</ul>
<p>Please remember that video calling may consume regular data if your free quota limit is reached. To check your remaining free WhatsApp data balance, dial <strong>*102#</strong>.</p>
''',
        date: DateTime.now().subtract(const Duration(days: 4)),
        link: 'https://techshiner.com/zong-free-whatsapp-guide',
        featuredMediaUrl:
            'https://images.unsplash.com/photo-1611746872915-64382b5c76da?auto=format&fit=crop&w=800&q=80',
        authorName: 'Tech Shiner Team',
      ),
      BlogPostModel(
        id: 'ts_telenor_morning_trick',
        title: 'Telenor Internet Settings & Free Morning MBs: Secret USSD Codes',
        excerpt:
            'Learn how to configure high-speed 4G internet settings and claim free morning data bundles on Telenor Pakistan.',
        content: '''
<p>Having optimal 4G APN configurations ensures maximum browsing speeds on Telenor Pakistan. Furthermore, Telenor regularly provides early morning bonus internet.</p>
<h2>Free Morning Browsing Trick</h2>
<p>Subscribers who dial <strong>*888#</strong> between 6:00 AM and 9:00 AM receive complimentary 500 MB fast 4G data for dawn browsing and social checks.</p>
<h2>Manual APN Internet Settings</h2>
<p>If your mobile data is sluggish or not connecting, configure these access points manually:</p>
<ul>
  <li><strong>Name:</strong> Telenor 4G</li>
  <li><strong>APN:</strong> internet</li>
  <li><strong>MCC:</strong> 410</li>
  <li><strong>MNC:</strong> 06</li>
  <li><strong>APN Protocol:</strong> IPv4/IPv6</li>
</ul>
<p>Restart your handset after saving the APN parameters to enjoy full LTE carrier speeds.</p>
''',
        date: DateTime.now().subtract(const Duration(days: 6)),
        link: 'https://techshiner.com/telenor-internet-settings-codes',
        featuredMediaUrl:
            'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        authorName: 'Tech Shiner Team',
      ),
      BlogPostModel(
        id: 'ts_save_mobile_data',
        title: 'How to Save Mobile Data & Stop Background Internet Drain in Pakistan',
        excerpt:
            'Practical tips to prevent mobile balance consumption and stop unseen background data usage on Android and iOS.',
        content: '''
<p>Mobile data in Pakistan can drain quickly due to hidden app synchronizations, system auto-updates, and cloud backups running in the background.</p>
<h2>Essential Data Saving Steps</h2>
<ul>
  <li><strong>Enable Data Saver:</strong> Open Android Settings &gt; Network &amp; Internet &gt; Data Saver and turn it ON. This stops non-essential apps from sending or receiving data in the background.</li>
  <li><strong>Disable Google Play Auto-Updates over Mobile Data:</strong> Set app auto-updates to "Over Wi-Fi only" inside Google Play Store settings.</li>
  <li><strong>Restrict Social Media Media Auto-Download:</strong> In WhatsApp settings, navigate to Storage and Data &gt; Media Auto-Download, and uncheck mobile data download for photos and videos.</li>
  <li><strong>Activate Telecom Balance Save Services:</strong> Dial network balance lock codes (e.g., Jazz Doosra Balance Saver *275#) to avoid balance loss when packages expire.</li>
</ul>
''',
        date: DateTime.now().subtract(const Duration(days: 9)),
        link: 'https://techshiner.com/save-mobile-data-pakistan',
        featuredMediaUrl:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80',
        authorName: 'Tech Shiner Team',
      ),
      BlogPostModel(
        id: 'ts_ufone_super_cards',
        title: 'Ufone Super Card Family Compared: Which Plan Gives You Best Value?',
        excerpt:
            'An in-depth breakdown of Ufone Super Card Max, Gold, and Plus to find the optimal bundle for your budget.',
        content: '''
<p>Ufone pioneered all-in-one "Super Cards" in Pakistan, combining on-net minutes, off-net call time, SMS, and high-speed internet data into a single hassle-free monthly recharge.</p>
<h2>Key Plans at a Glance</h2>
<ul>
  <li><strong>Super Card Grand:</strong> Ideal for budget voice callers with balanced 4G data.</li>
  <li><strong>Super Card Max:</strong> Offers massive internet buckets (20+ GB) alongside generous off-net minutes for all network calling.</li>
  <li><strong>Sab Se Badi Super Card:</strong> Maximum convenience for heavy business and remote work users who need unmetered connectivity.</li>
</ul>
<p>Always review recharge requirements before subscribing to ensure full balance coverage after tax deductions.</p>
''',
        date: DateTime.now().subtract(const Duration(days: 12)),
        link: 'https://techshiner.com/ufone-super-cards-comparison',
        featuredMediaUrl:
            'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=800&q=80',
        authorName: 'Tech Shiner Team',
      ),
    ];
  }
}

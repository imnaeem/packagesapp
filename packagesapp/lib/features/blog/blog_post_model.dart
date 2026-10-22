import 'package:intl/intl.dart';

class BlogPostModel {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final DateTime date;
  final String link;
  final String featuredMediaUrl;
  final String authorName;

  const BlogPostModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.link,
    required this.featuredMediaUrl,
    required this.authorName,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    // Title parsing
    String rawTitle = '';
    if (json['title'] is Map) {
      rawTitle = json['title']['rendered']?.toString() ?? '';
    } else {
      rawTitle = json['title']?.toString() ?? '';
    }
    final cleanTitle = _cleanHtml(rawTitle);

    // Excerpt parsing
    String rawExcerpt = '';
    if (json['excerpt'] is Map) {
      rawExcerpt = json['excerpt']['rendered']?.toString() ?? '';
    } else {
      rawExcerpt = json['excerpt']?.toString() ?? '';
    }
    final cleanExcerpt = _cleanHtml(rawExcerpt);

    // Content parsing
    String rawContent = '';
    if (json['content'] is Map) {
      rawContent = json['content']['rendered']?.toString() ?? '';
    } else {
      rawContent = json['content']?.toString() ?? '';
    }

    // Featured media url
    String mediaUrl = '';
    if (json['featured_media_url'] != null &&
        json['featured_media_url'].toString().isNotEmpty) {
      mediaUrl = json['featured_media_url'].toString();
    } else if (json['featured_image_url'] != null &&
        json['featured_image_url'].toString().isNotEmpty) {
      mediaUrl = json['featured_image_url'].toString();
    } else if (json['_embedded'] is Map) {
      final embedded = json['_embedded'] as Map<String, dynamic>;
      final wpMedia = embedded['wp:featuredmedia'];
      if (wpMedia is List && wpMedia.isNotEmpty && wpMedia.first is Map) {
        final mediaObj = wpMedia.first as Map<String, dynamic>;
        mediaUrl = mediaObj['source_url']?.toString() ?? '';
        if (mediaUrl.isEmpty && mediaObj['media_details'] is Map) {
          final sizes = mediaObj['media_details']['sizes'];
          if (sizes is Map && sizes['medium_large'] is Map) {
            mediaUrl = sizes['medium_large']['source_url']?.toString() ?? '';
          }
        }
      }
    }

    // Author
    String author = 'Tech Shiner';
    if (json['author_name'] != null &&
        json['author_name'].toString().isNotEmpty) {
      author = json['author_name'].toString();
    } else if (json['_embedded'] is Map) {
      final embedded = json['_embedded'] as Map<String, dynamic>;
      final authors = embedded['author'];
      if (authors is List && authors.isNotEmpty && authors.first is Map) {
        author = authors.first['name']?.toString() ?? 'Tech Shiner';
      }
    }

    // Date
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      parsedDate =
          DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    }

    return BlogPostModel(
      id: json['id']?.toString() ?? '',
      title: cleanTitle.isNotEmpty ? cleanTitle : 'Telecom Guide & Updates',
      excerpt: cleanExcerpt,
      content: rawContent,
      date: parsedDate,
      link: json['link']?.toString() ?? 'https://techshiner.com',
      featuredMediaUrl: mediaUrl,
      authorName: author,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'date': date.toIso8601String(),
        'link': link,
        'featured_media_url': featuredMediaUrl,
        'author_name': authorName,
      };

  int get readingTimeMinutes {
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final words = plainText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final minutes = (words / 180).ceil();
    return minutes > 0 ? minutes : 2;
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(date);

  static String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&hellip;', '...')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

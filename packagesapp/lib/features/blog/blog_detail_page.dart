import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_utils.dart';
import 'blog_post_model.dart';
import 'blog_repository.dart';

class BlogDetailPage extends ConsumerWidget {
  final String postId;
  final BlogPostModel? post;

  const BlogDetailPage({
    super.key,
    required this.postId,
    this.post,
  });

  Future<void> _openInBrowser(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open browser')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening browser: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Use passed post or lookup in provider
    BlogPostModel? article = post;
    if (article == null) {
      final postsAsync = ref.watch(blogPostsProvider);
      article = postsAsync.whenOrNull(
        data: (list) {
          try {
            return list.firstWhere((p) => p.id == postId);
          } catch (_) {
            return null;
          }
        },
      );
    }

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final postItem = article;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // Collapsible or clean SliverAppBar with Cover Photo
          SliverAppBar(
            expandedHeight:
                postItem.featuredMediaUrl.isNotEmpty ? 240.0 : 120.0,
            pinned: true,
            titleSpacing: 0,
            title: Text(
              'Article',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Article',
                onPressed: () {
                  AppUtils.hapticLight();
                  Share.share(
                    '${postItem.title}\n\nRead more on Tech Shiner:\n${postItem.link}',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser_rounded),
                tooltip: 'Open in Browser',
                onPressed: () => _openInBrowser(context, postItem.link),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: postItem.featuredMediaUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: postItem.featuredMediaUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.article_outlined,
                              size: 48,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                                cs.surface.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.15),
                            cs.surface,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
            ),
          ),

          // Article Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info: Author & Date & Reading time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_rounded,
                                size: 13, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              postItem.authorName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        postItem.formattedDate,
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(width: 6),
                      Text(
                        '${postItem.readingTimeMinutes} min read',
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Article Title
                  Text(
                    postItem.title,
                    style: AppTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: cs.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),

                  // Native formatted body
                  _NativeArticleBody(htmlContent: postItem.content),

                  const SizedBox(height: 32),
                  Divider(color: cs.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 20),

                  // Bottom Action Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerHigh
                          : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.language_rounded,
                                color: cs.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Published on Tech Shiner',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'techshiner.com • Tech & Telecom Portal',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  AppUtils.hapticLight();
                                  Share.share(
                                    '${postItem.title}\n\n${postItem.link}',
                                  );
                                },
                                icon: const Icon(Icons.share_outlined,
                                    size: 16),
                                label: const Text('Share'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openInBrowser(context, postItem.link),
                                icon: const Icon(
                                    Icons.open_in_browser_rounded,
                                    size: 16),
                                label: const Text('Open Web'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NativeArticleBody extends StatelessWidget {
  final String htmlContent;
  const _NativeArticleBody({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (htmlContent.isEmpty) {
      return Text(
        'No content available for this guide.',
        style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant),
      );
    }

    // Split HTML by tags to produce clean native blocks
    final blocks = _parseBlocks(htmlContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        switch (block.type) {
          case _BlockType.h2:
            return Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      block.text,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case _BlockType.h3:
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Text(
                block.text,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            );
          case _BlockType.bullet:
            return Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: _FormattedInlineText(rawHtml: block.text),
                  ),
                ],
              ),
            );
          case _BlockType.paragraph:
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FormattedInlineText(rawHtml: block.text),
            );
        }
      }).toList(),
    );
  }

  List<_ContentBlock> _parseBlocks(String html) {
    final blocks = <_ContentBlock>[];

    // Normalize breaks
    final normalized = html
        .replaceAll('\r\n', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n');

    final elementRegex = RegExp(
      r'<(h2|h3|p|li)[^>]*>(.*?)</\1>',
      caseSensitive: false,
      dotAll: true,
    );

    final matches = elementRegex.allMatches(normalized);
    if (matches.isEmpty) {
      // Fallback: split by double newlines
      final paragraphs = normalized.split(RegExp(r'\n{2,}'));
      for (final p in paragraphs) {
        final trimmed = p.trim();
        if (trimmed.isNotEmpty) {
          blocks.add(_ContentBlock(_BlockType.paragraph, trimmed));
        }
      }
      return blocks;
    }

    for (final match in matches) {
      final tag = match.group(1)!.toLowerCase();
      final inner = match.group(2)!.trim();
      if (inner.isEmpty) continue;

      switch (tag) {
        case 'h2':
          blocks.add(_ContentBlock(_BlockType.h2, _stripTags(inner)));
          break;
        case 'h3':
          blocks.add(_ContentBlock(_BlockType.h3, _stripTags(inner)));
          break;
        case 'li':
          blocks.add(_ContentBlock(_BlockType.bullet, inner));
          break;
        case 'p':
        default:
          blocks.add(_ContentBlock(_BlockType.paragraph, inner));
          break;
      }
    }

    return blocks;
  }

  String _stripTags(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

enum _BlockType { h2, h3, paragraph, bullet }

class _ContentBlock {
  final _BlockType type;
  final String text;
  _ContentBlock(this.type, this.text);
}

class _FormattedInlineText extends StatelessWidget {
  final String rawHtml;
  const _FormattedInlineText({required this.rawHtml});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseStyle = AppTextStyles.bodyMedium.copyWith(
      color: cs.onSurface.withValues(alpha: 0.9),
      height: 1.6,
      fontSize: 14.5,
    );

    // Parse strong / bold tags inside text
    final spans = <TextSpan>[];
    final parts = rawHtml.split(RegExp(r'(?=<strong>|<b>)|(?<=</strong>|</b>)'));

    for (final part in parts) {
      if (part.startsWith('<strong>') || part.startsWith('<b>')) {
        final clean = _cleanPart(part);
        spans.add(
          TextSpan(
            text: clean,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        );
      } else {
        final clean = _cleanPart(part);
        if (clean.isNotEmpty) {
          spans.add(TextSpan(text: clean, style: baseStyle));
        }
      }
    }

    if (spans.isEmpty) {
      return Text(_cleanPart(rawHtml), style: baseStyle);
    }

    if (spans.length == 1 && spans.first.style == baseStyle) {
      return Text(spans.first.text ?? '', style: baseStyle);
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _cleanPart(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

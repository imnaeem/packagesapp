import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_text_styles.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  // fast.com is clean, mobile-friendly, and auto-starts the test
  static const _url = 'https://fast.com';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _loadingProgress = p),
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.speed_rounded, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            const Text('Speed Test'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart test',
            onPressed: () => _controller.loadRequest(Uri.parse(_url)),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress < 100 ? _loadingProgress / 100 : null,
                  backgroundColor: Colors.transparent,
                  color: cs.primary,
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark
                ? cs.primary.withOpacity(0.08)
                : cs.primary.withOpacity(0.05),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Powered by fast.com — test auto-starts. Tap refresh to retest.',
                    style: AppTextStyles.caption.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),

          // Tips section
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest.withOpacity(0.5) : cs.surface,
              border: Border(top: BorderSide(color: cs.outline.withOpacity(0.15))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TipChip(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  hint: 'Streaming & browsing',
                  color: cs.primary,
                ),
                _TipChip(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  hint: 'Sending files',
                  color: Colors.orange,
                ),
                _TipChip(
                  icon: Icons.timer_outlined,
                  label: 'Latency',
                  hint: 'Gaming & calls',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;

  const _TipChip({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        Text(
          hint,
          style: TextStyle(
            fontSize: 9,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

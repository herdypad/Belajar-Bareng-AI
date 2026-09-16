import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class GoogleSearchWebViewSheet extends StatefulWidget {
  final String query;

  const GoogleSearchWebViewSheet({super.key, required this.query});

  static Future<void> show(BuildContext context, {required String query}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value();

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: isTablet ? 720 : double.infinity,
      ),
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: GoogleSearchWebViewSheet(query: trimmed),
        ),
      ),
    );
  }

  @override
  State<GoogleSearchWebViewSheet> createState() =>
      _GoogleSearchWebViewSheetState();
}

class _GoogleSearchWebViewSheetState extends State<GoogleSearchWebViewSheet> {
  WebViewController? _webViewController;
  double _loadingProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSupportedPlatform = false;

  Uri get _searchUri => Uri.parse(
        'https://www.google.com/search?q=${Uri.encodeComponent(widget.query)}',
      );

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // webview_flutter secara native mendukung Android dan iOS
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _isSupportedPlatform = true;
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _loadingProgress = progress / 100.0;
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = error.description;
                  });
                }
              },
            ),
          )
          ..loadRequest(_searchUri);
      } else {
        _isSupportedPlatform = false;
        _isLoading = false;
      }
    } catch (_) {
      _isSupportedPlatform = false;
      _isLoading = false;
    }
  }

  Future<void> _openExternalBrowser() async {
    try {
      await launchUrl(_searchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka browser: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    final height = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: s.border),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: s.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pencarian Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: s.muted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSupportedPlatform && _webViewController != null)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Muat Ulang',
                    onPressed: () => _webViewController?.reload(),
                  ),
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  tooltip: 'Buka di Browser',
                  onPressed: _openExternalBrowser,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Loading Progress Bar
          if (_isLoading && _isSupportedPlatform)
            LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress : null,
              minHeight: 2.5,
              backgroundColor: s.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            )
          else
            Divider(height: 1, color: s.border),

          // Web View or Fallback Content
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final s = context.surfaces;

    if (!_isSupportedPlatform || _webViewController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cari di Google',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '"${widget.query}"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: s.muted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openExternalBrowser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: const Text('Buka di Browser'),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Halaman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: s.muted),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _webViewController?.reload();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Coba Lagi'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openExternalBrowser,
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Buka Browser'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return WebViewWidget(controller: _webViewController!);
  }
}

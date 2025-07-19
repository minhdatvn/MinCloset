// lib/screens/webview_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/services/web_cache_service.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';


class WebViewPageArgs {
  final String title;
  final String url;
  const WebViewPageArgs({required this.title, required this.url});
}

class WebViewPage extends ConsumerStatefulWidget {
  final WebViewPageArgs args;
  const WebViewPage({super.key, required this.args});

  @override
  ConsumerState<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends ConsumerState<WebViewPage> {
  String? _filePath;
  WebViewController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAndCacheFile();
  }

  Future<void> _loadAndCacheFile() async {
    final webCacheService = ref.read(webCacheServiceProvider);
    final path = await webCacheService.getCachedFilePath(widget.args.url);

    if (!mounted) return;

    if (path != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
      
      // Cấp quyền đọc file cho WebView trên Android
      if (Platform.isAndroid) {
        // Giờ đây 'AndroidWebViewController' đã được nhận diện
        final androidController = (_controller!.platform as AndroidWebViewController);
        await androidController.setAllowFileAccess(true);
      }

      setState(() {
        _filePath = path;
        _controller!.loadRequest(Uri.file(path));
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(
        title: Text(widget.args.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_filePath == null && !_hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Could not load content. Please check your internet connection and try again.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return WebViewWidget(controller: _controller!);
  }
}
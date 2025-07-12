// lib/screens/webview_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Lớp để truyền tham số cho màn hình
class WebViewPageArgs {
  final String title;
  final String url;

  const WebViewPageArgs({required this.title, required this.url});
}

class WebViewPage extends StatefulWidget {
  final WebViewPageArgs args;
  const WebViewPage({super.key, required this.args});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.args.url));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(
        title: Text(widget.args.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
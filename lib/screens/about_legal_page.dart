// lib/screens/about_legal_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/routing/app_routes.dart'; // <<< THÊM IMPORT
import 'package:mincloset/screens/webview_page.dart'; // <<< THÊM IMPORT
import 'package:package_info_plus/package_info_plus.dart';

class AboutLegalPage extends StatelessWidget {
  const AboutLegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Legal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data.'),
            onTap: () {
              // --- THAY ĐỔI Ở ĐÂY ---
              Navigator.pushNamed(
                context,
                AppRoutes.webview,
                arguments: const WebViewPageArgs(
                  title: 'Privacy Policy',
                  url:'https://minhdatvn.github.io/MinCloset/privacy-policy.html'
           ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of Use'),
            subtitle: const Text('Rules for using the app.'),
            onTap: () {
              // --- THAY ĐỔI Ở ĐÂY ---
              Navigator.pushNamed(
                context,
                AppRoutes.webview,
                arguments: const WebViewPageArgs(
                  title: 'Terms of Use',
                  url: 'https://minhdatvn.github.io/MinCloset/terms-of-use.html'
                )
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('Open Source Licenses'),
            subtitle: const Text('Libraries that make MinCloset possible.'),
            onTap: () async {
              // Lấy thông tin phiên bản một cách tự động
              final packageInfo = await PackageInfo.fromPlatform();
              if (context.mounted) {
                showLicensePage(
                  context: context,
                  applicationName: 'MinCloset',
                  applicationVersion: packageInfo.version,
                  applicationIcon: const Icon(Icons.checkroom, size: 48), // Tùy chọn
                );
              }
            },
          ),
          const Divider(height: 48),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                  : 'Loading version...';
              return Center(
                child: Text(
                  version,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
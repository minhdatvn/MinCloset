// lib/screens/about_legal_page.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutLegalPage extends StatelessWidget {
  const AboutLegalPage({super.key});

  // Hàm helper để mở URL
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

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
              // TODO: Thay thế bằng URL Privacy Policy của bạn
              _launchUrl(context, 'https://github.com/minhdatvn');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of Use'),
            subtitle: const Text('Rules for using the app.'),
            onTap: () {
              // TODO: Thay thế bằng URL Terms of Use của bạn
              _launchUrl(context, 'https://github.com/minhdatvn');
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
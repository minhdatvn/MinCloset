// lib/screens/about_legal_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/routing/app_routes.dart'; // <<< THÊM IMPORT
import 'package:mincloset/screens/webview_page.dart'; // <<< THÊM IMPORT
import 'package:package_info_plus/package_info_plus.dart';

class AboutLegalPage extends StatelessWidget {
  const AboutLegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.about_privacy_title),
            subtitle: Text(l10n.about_privacy_subtitle),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.webview,
                arguments: WebViewPageArgs(
                  title: l10n.about_privacy_title,
                  url:'https://minhdatvn.github.io/MinCloset/privacy-policy.html'
           ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l10n.about_terms_title),
            subtitle: Text(l10n.about_terms_subtitle),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.webview,
                arguments: WebViewPageArgs(
                  title: l10n.about_terms_title,
                  url: 'https://minhdatvn.github.io/MinCloset/terms-of-use.html'
                )
              );
            },
          ),
          
          const Divider(height: 48),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? l10n.about_version(snapshot.data!.version, snapshot.data!.buildNumber)
                  : l10n.about_loadingVersion;
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
// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/profile_page_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('Tiếng Việt'),
                value: const Locale('vi'),
                groupValue: currentLocale,
                onChanged: (locale) {
                  if (locale != null) {
                    ref.read(localeProvider.notifier).setLocale(locale.languageCode);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (locale) {
                  if (locale != null) {
                    ref.read(localeProvider.notifier).setLocale(locale.languageCode);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Location'),
            subtitle: Text(state.cityMode == CityMode.auto
                ? 'Auto-detect'
                : state.manualCity),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.citySelection);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: Text(locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    // ... logic của hàm này được giữ nguyên ...
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
    final notifier = ref.read(profileProvider.notifier);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- NHÓM 1: CÀI ĐẶT CHUNG ---
          const _SectionTitle('General Settings'),
          _SettingsTile(
            icon: Icons.public_outlined,
            title: 'Localization',
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.location_city_outlined,
                  title: 'Location',
                  subtitle: Text(state.cityMode == CityMode.auto ? 'Auto-detect' : state.manualCity),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.citySelection),
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: Text(locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English'),
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.paid_outlined,
                  title: 'Currency',
                  trailing: DropdownButton<String>(
                    value: state.currency,
                    underline: const SizedBox(),
                    items: ['VND', 'USD', 'EUR']
                        .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        notifier.updateFormattingSettings(currency: newValue);
                      }
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.pin_outlined,
                  title: 'Decimal format',
                  trailing: DropdownButton<NumberFormatType>(
                    value: state.numberFormat,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: NumberFormatType.dotDecimal,
                        child: Text('.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      DropdownMenuItem(
                        value: NumberFormatType.commaDecimal,
                        child: Text(',', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    onChanged: (NumberFormatType? newValue) {
                      if (newValue != null) {
                        notifier.updateFormattingSettings(format: newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          _SettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Display',
            child: SwitchListTile(
              title: const Text('Show weather background'),
              subtitle: const Text('Display image based on weather'),
              value: state.showWeatherImage,
              onChanged: (bool value) {
                notifier.updateShowWeatherImage(value);
              },
              secondary: const Icon(Icons.image_outlined),
            ),
          ),
          const Divider(height: 32),

          // --- NHÓM 2: GIỚI THIỆU & HỖ TRỢ ---
          const _SectionTitle('About & Support'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About & Legal',
            onTap: () => Navigator.pushNamed(context, AppRoutes.aboutLegal),
          ),
          _SettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: const Text('Help us improve MinCloset'),
            onTap: () {
              // TODO: Implement logic to open email or a feedback form
            },
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Rate on App Store',
            onTap: () {
              // TODO: Implement logic to open app store page
            },
          ),
        ],
      ),
    );
  }
}

// Widget helper để tạo tiêu đề cho mỗi nhóm
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// Widget helper để tạo các ListTile cài đặt cho gọn
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? child;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Icon(icon),
          title: Text(title),
          childrenPadding: const EdgeInsets.only(left: 16),
          children: [child!],
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
        onTap: onTap,
      ),
    );
  }
}
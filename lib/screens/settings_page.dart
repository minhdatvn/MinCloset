// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/src/providers/notification_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy state từ các provider
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final locale = ref.watch(localeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
    // --- LẤY SERVICE ĐỂ GỌI HÀM TEST ---
    final notificationService = ref.read(localNotificationServiceProvider);

    return PageScaffold(
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
                  subtitle: Text(profileState.cityMode == CityMode.auto ? 'Auto-detect' : profileState.manualCity),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.citySelection),
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: Text(locale.languageCode == 'en' ? 'English' : 'Tiếng Việt'),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.languageSelection),
                ),
                _SettingsTile(
                  icon: Icons.paid_outlined,
                  title: 'Currency',
                  trailing: DropdownButton<String>(
                    value: profileState.currency,
                    underline: const SizedBox(),
                    items: ['VND', 'USD', 'EUR']
                        .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        profileNotifier.updateFormattingSettings(currency: newValue);
                      }
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.pin_outlined,
                  title: 'Decimal format',
                  trailing: DropdownButton<NumberFormatType>(
                    value: profileState.numberFormat,
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
                        profileNotifier.updateFormattingSettings(format: newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // --- KHỐI CÀI ĐẶT THÔNG BÁO ---
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable all notifications'),
                  value: notificationSettings.isMasterEnabled,
                  onChanged: (bool value) {
                    notificationNotifier.updateMaster(value);
                  },
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Morning reminder (7:00)'),
                  subtitle: const Text('Get suggestions for your daily outfit plan.'),
                  value: notificationSettings.isMorningReminderEnabled,
                  onChanged: notificationSettings.isMasterEnabled
                      ? (bool value) {
                          notificationNotifier.updateMorning(value);
                        }
                      : null,
                  secondary: const Icon(Icons.wb_sunny_outlined),
                ),
                // --- NÚT TEST THÔNG BÁO BUỔI SÁNG ---
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        notificationService.showNow(
                          0, // ID
                          "Good Morning! ☀️", // Title
                          "The weather is nice today! What will you wear to shine? Let's plan it!", // Body
                        );
                      },
                      child: const Text('Test Morning'),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Evening reminder (20:00)'),
                  subtitle: const Text('Remind to update your fashion journal.'),
                  value: notificationSettings.isEveningReminderEnabled,
                  onChanged: notificationSettings.isMasterEnabled
                      ? (bool value) {
                          notificationNotifier.updateEvening(value);
                        }
                      : null,
                  secondary: const Icon(Icons.mode_night_outlined),
                ),
                // --- NÚT TEST THÔNG BÁO BUỔI TỐI ---
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        notificationService.showNow(
                          1, // ID
                          "Daily Mission! ✨", // Title
                          "One small step every day. Don't forget to update your fashion journal!", // Body
                        );
                      },
                      child: const Text('Test Evening'),
                    ),
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
              value: profileState.showWeatherImage,
              onChanged: (bool value) {
                profileNotifier.updateShowWeatherImage(value);
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
              // TODO: Implement logic
            },
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Rate on App Store',
            onTap: () {
              // TODO: Implement logic
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
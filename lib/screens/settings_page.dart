// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/src/providers/notification_providers.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/widgets/section_header.dart'; 

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Lấy state từ các provider
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final locale = ref.watch(localeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationNotifier = ref.read(notificationSettingsProvider.notifier);

    return PageScaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- NHÓM 1: CÀI ĐẶT CHUNG ---
          SectionHeader(title: context.l10n.settings_general_sectionHeader), 
          _SettingsTile(
            icon: Icons.public_outlined,
            title: context.l10n.settings_localization_tile,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.location_city_outlined,
                  title: context.l10n.settings_location_tile,
                  subtitle: Text(profileState.cityMode == CityMode.auto
                      ? context.l10n.settings_autoDetect_label
                      : profileState.manualCity),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.citySelection),
                ),
               _SettingsTile(
                  icon: Icons.language_outlined,
                  title: context.l10n.settings_language_tile,
                  subtitle: Text(locale.languageCode == 'en'
                      ? context.l10n.language_english
                      : context.l10n.language_vietnamese),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.languageSelection),
                ),
              ],
            ),
          ),
          _SettingsTile(
            icon: Icons.straighten_outlined,
            title: context.l10n.settings_units_tile,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Symbols.height,
                  title: context.l10n.settings_height_label,
                  trailing: DropdownButton<HeightUnit>(
                    value: profileState.heightUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: HeightUnit.cm, child: Text("cm")),
                      DropdownMenuItem(value: HeightUnit.ft, child: Text("ft")),
                    ],
                    onChanged: (HeightUnit? newValue) {
                      if (newValue != null) {
                        profileNotifier.updateMeasurementUnits(height: newValue);
                      }
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Symbols.weight,
                  title: context.l10n.settings_weight_label,
                  trailing: DropdownButton<WeightUnit>(
                    value: profileState.weightUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: WeightUnit.kg, child: Text("kg")),
                      DropdownMenuItem(value: WeightUnit.lbs, child: Text("lbs")),
                    ],
                    onChanged: (WeightUnit? newValue) {
                      if (newValue != null) {
                        profileNotifier.updateMeasurementUnits(weight: newValue);
                      }
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Symbols.device_thermostat,
                  title: context.l10n.settings_temp_label,
                  trailing: DropdownButton<TempUnit>(
                    value: profileState.tempUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: TempUnit.celsius, child: Text("°C")),
                      DropdownMenuItem(value: TempUnit.fahrenheit, child: Text("°F")),
                    ],
                    onChanged: (TempUnit? newValue) {
                      if (newValue != null) {
                        profileNotifier.updateMeasurementUnits(temp: newValue);
                      }
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.paid_outlined,
                  title: context.l10n.settings_currency_tile,
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
                  title: context.l10n.settings_decimalFormat_tile,
                  trailing: DropdownButton<NumberFormatType>(
                    value: profileState.numberFormat,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: NumberFormatType.commaDecimal,
                        child: Text("1.000,00"),
                      ),
                      DropdownMenuItem(
                        value: NumberFormatType.dotDecimal,
                        child: Text("1,000.00"),
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
            title: context.l10n.settings_notifications_tile,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(context.l10n.settings_enableAllNotifications_label),
                  subtitle: Text(
                      context.l10n.settings_dailyReminderDescription,),
                  // Lấy giá trị từ model state mới
                  value: notificationSettings.isEnabled,
                  onChanged: (bool value) {
                    // Gọi hàm update trong notifier mới
                    notificationNotifier.updateMaster(value);
                  },
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
          ),

          _SettingsTile(
            icon: Icons.visibility_outlined,
            title: context.l10n.settings_display_tile,
            child: Column( // <<< Bọc các cài đặt hiển thị trong một Column
              children: [
                SwitchListTile(
                  title: Text(context.l10n.settings_showWeatherBg_label),
                  subtitle: Text(context.l10n.settings_showWeatherBg_subtitle),
                  value: profileState.showWeatherImage,
                  onChanged: (bool value) {
                    profileNotifier.updateShowWeatherImage(value);
                  },
                  secondary: const Icon(Icons.image_outlined),
                ),

                SwitchListTile(
                  title: const Text("Show Help Tooltips"), // Sẽ đa ngôn ngữ sau
                  subtitle: const Text("Display (?) icons for helpful tips."),
                  value: profileState.showTooltips,
                  onChanged: (bool value) {
                    profileNotifier.updateShowTooltips(value);
                  },
                  secondary: const Icon(Icons.help_outline),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    // Lấy provider quản lý trạng thái hiển thị của mascot
                    final isMascotEnabled = ref.watch(profileProvider.select((s) => s.showMascot));
                    return SwitchListTile(
                      title: Text(context.l10n.settings_showMascot_label),
                      subtitle: Text(context.l10n.settings_showMascot_subtitle),
                      value: isMascotEnabled,
                      onChanged: (value) {
                        // Gọi notifier để cập nhật và lưu cài đặt
                        ref.read(profileProvider.notifier).updateShowMascot(value);
                      },
                      secondary: const Icon(Symbols.siren_check_rounded),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          // --- NHÓM 2: GIỚI THIỆU & HỖ TRỢ ---
          SectionHeader(title: context.l10n.settings_aboutSupport_sectionHeader),
          _SettingsTile(
            icon: Icons.info_outline,
            title: context.l10n.settings_aboutLegal_tile,
            onTap: () => Navigator.pushNamed(context, AppRoutes.aboutLegal),
          ),
          _SettingsTile(
            icon: Icons.feedback_outlined,
            title: context.l10n.settings_sendFeedback_tile,
            subtitle: Text(context.l10n.settings_sendFeedback_subtitle),
            onTap: () {
              // TODO: Implement logic
            },
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: context.l10n.settings_rateApp_tile,
            onTap: () {
              // TODO: Implement logic
            },
          ),
        ],
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
// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/city_preference_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vẫn đọc state từ profileProvider để hiển thị thông tin hiện tại
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Thành phố mặc định cho Thời tiết'),
            subtitle: Text(state.cityMode == CityMode.auto
                ? 'Tự động theo vị trí'
                : state.manualCity),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                // Dialog sẽ được nâng cấp ở bước sau
                builder: (context) => const CityPreferenceDialog(),
              );
            },
          ),
          const Divider(),
          // Sau này bạn có thể thêm các cài đặt khác ở đây
          // Ví dụ: ListTile(title: Text('Giao diện Sáng/Tối')),
        ],
      ),
    );
  }
}
// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
// <<< THÊM IMPORT MÀN HÌNH MỚI >>>
import 'package:mincloset/screens/city_selection_screen.dart';
import 'package:mincloset/states/profile_page_state.dart';
// <<< XÓA IMPORT DIALOG CŨ >>>
// import 'package:mincloset/widgets/city_preference_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // <<< THAY THẾ showDialog BẰNG Navigator.push >>>
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const CitySelectionScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
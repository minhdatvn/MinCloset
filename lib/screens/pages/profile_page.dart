// lib/screens/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart'; // <<< THÊM IMPORT CHO BIỂU ĐỒ

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadInitialData(),
            tooltip: 'Tải lại dữ liệu',
          )
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(BuildContext context, ProfilePageState state, ProfilePageNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.loadInitialData(),
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Phần thông tin cá nhân ---
          GestureDetector(
            onTap: () {
              notifier.updateAvatar();
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: state.avatarPath != null 
                      ? FileImage(File(state.avatarPath!)) 
                      : null,
                  child: state.avatarPath == null 
                      ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                      : null,
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.userName ?? 'Chưa có tên',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () {
                  _showEditNameDialog(context, notifier, state.userName ?? '');
                },
              )
            ],
          ),
          const Divider(height: 48),

          // --- Phần cài đặt ---
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt & Tùy chọn'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const Divider(),

          const SizedBox(height: 24),

          // --- Phần thống kê ---
          Text('Tổng quan Tủ đồ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Vật phẩm', state.totalItems.toString()),
                  _buildStatItem('Tủ đồ', state.totalClosets.toString()),
                  _buildStatItem('Bộ đồ', state.totalOutfits.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // <<< THAY THẾ WIDGET PLACEHOLDER BẰNG BIỂU ĐỒ THẬT
          Text('Phân tích', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StatsPieChart(
            title: 'Phân tích theo Màu sắc',
            dataMap: state.colorDistribution,
          ),
          const SizedBox(height: 16),
          StatsPieChart(
            title: 'Phân tích theo Danh mục',
            dataMap: state.categoryDistribution,
          ),
        ],
      ),
    );
  }

  // Hàm helper để hiển thị dialog đổi tên
  void _showEditNameDialog(BuildContext context, ProfilePageNotifier notifier, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đổi tên hiển thị'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Tên mới'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.updateUserName(nameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Hàm helper để build một ô thống kê
  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}
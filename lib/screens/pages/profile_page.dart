// lib/screens/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';

// <<< CHUYỂN `ProfilePage` THÀNH `ConsumerStatefulWidget` ĐỂ QUẢN LÝ STATE CỦA `PageController` >>>
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Controller cho PageView
  final PageController _pageController = PageController();
  // State để theo dõi trang đang được chọn
  int _activePageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      return Center( /* Error UI không đổi */ );
    }
    
    // <<< TẠO DANH SÁCH CÁC BIỂU ĐỒ ĐỂ DÙNG TRONG PAGEVIEW >>>
    final List<Widget> statCharts = [
      if (state.categoryDistribution.isNotEmpty)
        StatsPieChart(title: 'Theo Danh mục', dataMap: state.categoryDistribution),
      if (state.colorDistribution.isNotEmpty)
        StatsPieChart(title: 'Theo Màu sắc', dataMap: state.colorDistribution),
      if (state.seasonDistribution.isNotEmpty)
        StatsPieChart(title: 'Theo Mùa', dataMap: state.seasonDistribution),
      if (state.occasionDistribution.isNotEmpty)
        StatsPieChart(title: 'Theo Mục đích', dataMap: state.occasionDistribution),
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ... Phần thông tin cá nhân và cài đặt không đổi ...
          GestureDetector(
            onTap: () => notifier.updateAvatar(),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
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
                onPressed: () => _showEditNameDialog(context, notifier, state.userName ?? ''),
              )
            ],
          ),
          const Divider(height: 48),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt & Tùy chọn'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
          const Divider(),
          const SizedBox(height: 24),
          Text('Tổng quan Tủ đồ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StatsOverviewCard(
            totalItems: state.totalItems,
            totalClosets: state.totalClosets,
            totalOutfits: state.totalOutfits,
          ),
          const SizedBox(height: 24),

          // <<< THAY ĐỔI LỚN BẮT ĐẦU TỪ ĐÂY >>>

          // 1. Đổi tên tiêu đề
          Text('Thống kê', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (statCharts.isEmpty)
            const Text('Chưa có dữ liệu để thống kê.')
          else
            Column(
              children: [
                // 2. PageView để trượt ngang các biểu đồ
                SizedBox(
                  height: 300, // Giới hạn chiều cao cho PageView
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _activePageIndex = page;
                      });
                    },
                    children: statCharts,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 3. Dấu chấm chỉ báo trang hiện tại
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(statCharts.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _activePageIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _activePageIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ],
            )
        ],
      ),
    );
  }

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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
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
}
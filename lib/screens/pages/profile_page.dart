// lib/screens/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/screens/edit_profile_screen.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _activePageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildProfileHeader(ProfilePageState state) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: ref.read(profileProvider.notifier).updateAvatar,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    state.avatarPath != null ? FileImage(File(state.avatarPath!)) : null,
                child: state.avatarPath == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 80, // Chiều cao bằng với avatar để căn chỉnh
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userName ?? 'Chưa có tên',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Xem & chỉnh sửa thông tin',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // <<< CÁC WIDGET _buildInfoCard VÀ _buildInfoRow ĐÃ ĐƯỢC XÓA BỎ >>>

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
      // Widget xử lý lỗi không thay đổi
      return Center(
          child: Text(state.errorMessage!)
      );
    }

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

    return RefreshIndicator(
      onRefresh: notifier.loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(state),
            // <<< DÒNG GỌI _buildInfoCard(state) ĐÃ ĐƯỢC XÓA Ở ĐÂY >>>
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Cài đặt & Tùy chọn'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage())),
            ),
            const Divider(height: 32),
            Text('Tổng quan Tủ đồ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StatsOverviewCard(
              totalItems: state.totalItems,
              totalClosets: state.totalClosets,
              totalOutfits: state.totalOutfits,
            ),
            const SizedBox(height: 24),
            Text('Thống kê', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (statCharts.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text('Chưa có dữ liệu để thống kê.'),
              ))
            else
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: statCharts.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _activePageIndex = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: statCharts[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
      ),
    );
  }
}
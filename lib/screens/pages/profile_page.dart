// lib/screens/pages/profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _activePageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildProfileHeader(ProfilePageState state) {
  return Row(
    children: [
      // --- CỤM AVATAR ---
      Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Bọc CircleAvatar trong GestureDetector để xử lý việc nhấn vào avatar lớn
          GestureDetector(
            onTap: () => ref.read(profileProvider.notifier).updateAvatar(),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: state.avatarPath != null ? FileImage(File(state.avatarPath!)) : null,
              child: state.avatarPath == null
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          // Giữ nguyên icon edit nhỏ
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: () => ref.read(profileProvider.notifier).updateAvatar(),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 16),

      // --- CỤM TEXT ĐỂ ĐIỀU HƯỚNG ---
      // 2. Bọc phần text và mũi tên trong InkWell riêng để điều hướng
      Expanded(
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.editProfile);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName ?? 'Unnamed',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Edit profile',
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
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    return Scaffold(
      // --- THAY ĐỔI AppBar ---
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Thay nút refresh bằng nút settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            tooltip: 'Settings',
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
      return Center(child: Text(state.errorMessage!));
    }

    final List<Widget> statPages = [];
    if (state.categoryDistribution.isNotEmpty) {
      statPages.add(_buildStatPage('Category', state.categoryDistribution));
    }
    if (state.colorDistribution.isNotEmpty) {
      final sortedColorEntries = state.colorDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dynamicColors = sortedColorEntries
          .map((entry) => AppOptions.colors[entry.key] ?? Colors.grey)
          .toList();
      final sortedColorMap = Map.fromEntries(sortedColorEntries);
      statPages.add(_buildStatPage('Color', sortedColorMap, specificColors: dynamicColors));
    }
    if (state.seasonDistribution.isNotEmpty) {
      statPages.add(_buildStatPage('Season', state.seasonDistribution));
    }
    if (state.occasionDistribution.isNotEmpty) {
      statPages.add(_buildStatPage('Occasion', state.occasionDistribution));
    }
    if (state.materialDistribution.isNotEmpty) {
      statPages.add(_buildStatPage('Material', state.materialDistribution));
    }
    if (state.patternDistribution.isNotEmpty) {
      statPages.add(_buildStatPage('Pattern', state.patternDistribution));
    }

    return RefreshIndicator(
      onRefresh: notifier.loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(state),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline), // Đổi icon
              title: const Text('About & Legal'), // Đổi tiêu đề
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.aboutLegal), // Điều hướng đến trang mới
            ),
            const Divider(height: 32),

            Text('Closets overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StatsOverviewCard(
              totalItems: state.totalItems,
              totalClosets: state.totalClosets,
              totalOutfits: state.totalOutfits,
            ),
            const SizedBox(height: 24),
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (statPages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('No data for statistics'),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: statPages.length,
                      onPageChanged: (int page) {
                        setState(() { _activePageIndex = page; });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: statPages[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(statPages.length, (index) {
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

  // <<< HÀM ĐƯỢC THIẾT KẾ LẠI HOÀN CHỈNH >>>
  Widget _buildStatPage(String title, Map<String, int> dataMap, {List<Color>? specificColors}) {
    final totalValue = dataMap.values.fold(0, (sum, item) => sum + item);
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(4);

    const double chartSize = 90;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              // 1. Center widget để căn giữa toàn bộ nội dung (chart + chú giải)
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 2. Row chỉ chiếm không gian cần thiết
                  children: [
                    // --- BIỂU ĐỒ TRÒN ---
                    SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: StatsPieChart(
                        title: '',
                        dataMap: dataMap,
                        showChartTitle: false,
                        colors: specificColors ?? AppChartColors.defaultChartColors,
                        size: chartSize,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // --- KHU VỰC CHÚ GIẢI ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: topEntries.map((entry) {
                        final percentage = (entry.value / totalValue * 100);
                        final color = (specificColors ?? AppChartColors.defaultChartColors)[sortedEntries.indexOf(entry) % (specificColors ?? AppChartColors.defaultChartColors).length];
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              // Chấm màu hình vuông bo góc
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 3. Kết hợp Tên và % trong cùng một Text
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(text: '${entry.key} '),
                                    TextSpan(
                                      text: '${percentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
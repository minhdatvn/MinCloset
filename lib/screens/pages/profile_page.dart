// lib/screens/pages/profile_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/theme/app_theme.dart';
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

  Future<void> _handleAvatarTap(AppLocalizations l10n) async {
    final navigator = Navigator.of(context);

    // 1. Hiển thị menu chọn nguồn ảnh
    final imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profile_takePhoto_label), // Dùng l10n
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profile_fromAlbum_label), // Dùng l10n
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (imageSource == null || !mounted) return;

    // 2. Chọn ảnh
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: imageSource);
    if (pickedFile == null || !mounted) return;

    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    // 3. Điều hướng đến màn hình cắt ảnh
    final croppedBytes = await navigator.pushNamed<Uint8List?>(
      AppRoutes.avatarCropper,
      arguments: imageBytes,
    );

    // 4. Gọi notifier để lưu kết quả
    if (croppedBytes != null && mounted) {
      await ref.read(profileProvider.notifier).saveAvatar(croppedBytes);
    }
  }

  Widget _buildProfileHeader(ProfilePageState state, AppLocalizations l10n) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // <<< GỌI HÀM _handleAvatarTap KHI NHẤN >>>
            GestureDetector(
              onTap: () => _handleAvatarTap(l10n),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: state.avatarPath != null ? FileImage(File(state.avatarPath!)) : null,
                child: state.avatarPath == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: () => _handleAvatarTap(l10n),
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
                            state.userName ?? l10n.profile_unnamed_label,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.profile_editProfile_label,
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
    final l10n = AppLocalizations.of(context)!; // Lấy l10n

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            tooltip: l10n.profile_settings_tooltip,
          )
        ],
      ),
      body: _buildBody(context, state, notifier, l10n),
    );
  }

  Widget _buildBody(BuildContext context, ProfilePageState state, ProfilePageNotifier notifier, AppLocalizations l10n) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    final List<Widget> statPages = [];
    if (state.categoryDistribution.isNotEmpty) {
      statPages.add(_buildStatPage(l10n.profile_statPage_category, state.categoryDistribution));
    }
    if (state.colorDistribution.isNotEmpty) {
      final sortedColorEntries = state.colorDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dynamicColors = sortedColorEntries
          .map((entry) => AppOptions.colors[entry.key] ?? Colors.grey)
          .toList();
      final sortedColorMap = Map.fromEntries(sortedColorEntries);
      statPages.add(_buildStatPage(l10n.profile_statPage_color, sortedColorMap, specificColors: dynamicColors));
    }
    if (state.seasonDistribution.isNotEmpty) {
      statPages.add(_buildStatPage(l10n.profile_statPage_season, state.seasonDistribution));
    }
    if (state.occasionDistribution.isNotEmpty) {
      statPages.add(_buildStatPage(l10n.profile_statPage_occasion, state.occasionDistribution));
    }
    if (state.materialDistribution.isNotEmpty) {
      statPages.add(_buildStatPage(l10n.profile_statPage_material, state.materialDistribution));
    }
    if (state.patternDistribution.isNotEmpty) {
      statPages.add(_buildStatPage(l10n.profile_statPage_pattern, state.patternDistribution));
    }

    return RefreshIndicator(
      onRefresh: notifier.loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildProfileHeader(state, l10n),
                  const Divider(height: 32),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.primary),
                      title: Text(l10n.profile_achievements_label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.quests);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.profile_closetsOverview_sectionHeader,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.closetInsights);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.profile_insights_button,
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatsOverviewCard(
                    totalItems: state.totalItems,
                    totalClosets: state.totalClosets,
                    totalOutfits: state.totalOutfits,
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.profile_statistics_sectionHeader, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            if (statPages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(l10n.profile_noData_message),
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
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPage(String title, Map<String, int> dataMap, {List<Color>? specificColors}) {
    final totalValue = dataMap.values.fold(0, (sum, item) => sum + item);
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(4);

    const double chartSize = 90;

    String truncateText(String text, int maxLength) {
      if (text.length <= maxLength) {
        return text;
      }
      return '${text.substring(0, maxLength)}...';
    }

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
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: topEntries.map((entry) {
                        final percentage = (entry.value / totalValue * 100);
                        final color = (specificColors ?? AppChartColors.defaultChartColors)[sortedEntries.indexOf(entry) % (specificColors ?? AppChartColors.defaultChartColors).length];
                        
                        final truncatedName = truncateText(entry.key, 10);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(text: '$truncatedName '),
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
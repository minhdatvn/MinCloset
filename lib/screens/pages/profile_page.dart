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
import 'package:mincloset/widgets/statistic_card.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/screens/webview_page.dart';

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

  /// Xử lý toàn bộ luồng chọn, cắt và lưu ảnh đại diện mới.
  Future<void> _handleAvatarTap(AppLocalizations l10n) async {
    final navigator = Navigator.of(context);
    final imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profile_takePhoto_label),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profile_fromAlbum_label),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (imageSource == null || !mounted) return;
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: imageSource);
    if (pickedFile == null || !mounted) return;
    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;
    final croppedBytes = await navigator.pushNamed<Uint8List?>(
      AppRoutes.avatarCropper,
      arguments: imageBytes,
    );
    if (croppedBytes != null && mounted) {
      await ref.read(profileProvider.notifier).saveAvatar(croppedBytes);
    }
  }

  /// Xây dựng phần đầu của trang, bao gồm ảnh đại diện và tên người dùng.
  Widget _buildProfileHeader(ProfilePageState state, AppLocalizations l10n) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
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

  /// Hàm build chính của Widget.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    
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

  /// Xây dựng phần thân chính có thể cuộn của trang Profile.
  Widget _buildBody(BuildContext context, ProfilePageState state, ProfilePageNotifier notifier, AppLocalizations l10n) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    final List<Widget> statPages = [];
    if (state.categoryDistribution.isNotEmpty) statPages.add(StatisticCard(title: l10n.profile_statPage_category, dataMap: state.categoryDistribution));
    if (state.colorDistribution.isNotEmpty) {
      final sortedColorEntries = state.colorDistribution.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final dynamicColors = sortedColorEntries.map((entry) => AppOptions.colors[entry.key] ?? Colors.grey).toList();
      final sortedColorMap = Map.fromEntries(sortedColorEntries);
      statPages.add(StatisticCard(title: l10n.profile_statPage_color, dataMap: sortedColorMap, specificColors: dynamicColors));
    }
    if (state.seasonDistribution.isNotEmpty) statPages.add(StatisticCard(title: l10n.profile_statPage_season, dataMap: state.seasonDistribution));
    if (state.occasionDistribution.isNotEmpty) statPages.add(StatisticCard(title: l10n.profile_statPage_occasion, dataMap: state.occasionDistribution));
    if (state.materialDistribution.isNotEmpty) statPages.add(StatisticCard(title: l10n.profile_statPage_material, dataMap: state.materialDistribution));
    if (state.patternDistribution.isNotEmpty) statPages.add(StatisticCard(title: l10n.profile_statPage_pattern, dataMap: state.patternDistribution));

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
                  // KHU VỰC TÀI KHOẢN ĐÃ ĐƯỢC XÓA KHỎI ĐÂY
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(Icons.school_outlined, color: Theme.of(context).colorScheme.primary),
                      title: const Text("Beginner Guides", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.guides);
                      },
                    ),
                  ),
                  const SizedBox(height: 8), // Thêm khoảng cách giữa 2 card
                  // Card 2: Dẫn đến trang FAQ
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
                      title: const Text("FAQ", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // 1. Lấy ngôn ngữ hiện tại từ provider
                        final locale = ref.read(localeProvider);
                        
                        // 2. Xác định URL dựa trên mã ngôn ngữ
                        final url = locale.languageCode == 'vi'
                            ? 'https://minhdatvn.github.io/MinCloset/faq_vi.html'
                            : 'https://minhdatvn.github.io/MinCloset/faq_en.html';

                        // 3. Điều hướng đến WebView với các tham số đúng
                        Navigator.pushNamed(
                          context,
                          AppRoutes.webview,
                          arguments: WebViewPageArgs(
                            title: "FAQ",
                            url: url,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  SectionHeader(
                    title: l10n.profile_closetsOverview_sectionHeader,
                    seeAllText: l10n.profile_insights_button,
                    onSeeAll: () {
                      Navigator.pushNamed(context, AppRoutes.closetInsights);
                    },
                  ),
                  const SizedBox(height: 8),
                  StatsOverviewCard(
                    totalItems: state.totalItems,
                    totalClosets: state.totalClosets,
                    totalOutfits: state.totalOutfits,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(title: l10n.profile_statistics_sectionHeader),
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
                    children: List.generate(statPages.length, (index) {
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
}
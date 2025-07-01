// lib/screens/pages/home_page.dart
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/widgets/gradient_action_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';
import 'package:mincloset/widgets/weekly_planner.dart';

final recentItemsProvider =
    FutureProvider.autoDispose<List<ClothingItem>>((ref) async {
  // Theo dõi trigger để làm mới provider khi item thay đổi
  ref.watch(itemChangedTriggerProvider); 
  
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  
  // Lấy kết quả Either từ repository
  final result = await itemRepo.getRecentItems(5);

  // Xử lý kết quả Either
  return result.fold(
    // (Left) Nếu thất bại, throw Exception để widget .when(error:..) bắt được
    (failure) => throw Exception(failure.message),
    // (Right) Nếu thành công, trả về danh sách items
    (items) => items,
  );
});

// <<< THAY ĐỔI 1: Chuyển thành ConsumerStatefulWidget >>>
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // <<< THAY ĐỔI 2: Thêm TextEditingController >>>
  final TextEditingController _purposeController = TextEditingController();
  int _currentPurposeLength = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller
    _purposeController.addListener(() {
      setState(() {
        _currentPurposeLength = _purposeController.text.length;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeProvider.notifier).refreshWeatherOnly();
      }
    });
  }

  @override
  void dispose() {
    // Hủy controller khi widget bị xóa
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref được truy cập thông qua `this.ref` trong State
    final homeState = ref.watch(homeProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildHeader(context, ref),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await ref.read(homeProvider.notifier).refreshWeatherOnly(), //Khi làm mới chỉ lấy thông tin thời tiết
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatsOverviewCard(
                totalItems: profileState.totalItems,
                totalClosets: profileState.totalClosets,
                totalOutfits: profileState.totalOutfits,
              ),
              const SizedBox(height: 32),
              _buildAiStylistSection(context, ref),
              const SizedBox(height: 32),
              const WeeklyPlanner(), // Thay thế _buildRecentlyAddedSection
              const SizedBox(height: 32),
              const SectionHeader(
                title: 'Outfit suggestion',
              ),
              const SizedBox(height: 16),
              // Truyền ref vào hàm build card
              _buildTodaysSuggestionCard(context, ref, homeState),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Các hàm build UI con không thay đổi, chỉ cần truyền ref nếu cần
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(profileProvider.select((state) => state.userName));
    final avatarPath = ref.watch(profileProvider.select((state) => state.avatarPath));

    return Row(
      children: [
        // Bọc avatar và text trong một InkWell
        InkWell(
          onTap: () {
            // Chuyển sang tab Profile (index = 3)
            ref.read(mainScreenIndexProvider.notifier).state = 3;
          },
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
                child: avatarPath == null
                    ? const Icon(Icons.person, size: 24, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello,',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(userName ?? 'User',
                      style: Theme.of(context).appBarTheme.titleTextStyle),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
            onPressed: () { /* TODO: Implement notifications */ },
            icon: const Icon(Icons.notifications_outlined, size: 28)),
      ],
    );
  }

  Widget _buildAiStylistSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader(title: 'Outfit Studio'),
        const SizedBox(height: 16),
        Row(
          children: [
            // SỬ DỤNG WIDGET MỚI
            GradientActionCard(
              label: 'Create outfits',
              icon: Icons.design_services_outlined,
              // THAY THẾ BẰNG ĐƯỜNG DẪN ẢNH CỦA BẠN
              imagePath: 'assets/images/cards/create_outfits_bg.webp', 
              onTap: () => Navigator.pushNamed(context, AppRoutes.outfitBuilder),
            ),
            const SizedBox(width: 16),
            // SỬ DỤNG WIDGET MỚI
            GradientActionCard(
              label: 'Saved outfits',
              icon: Icons.collections_bookmark_outlined,
              // THAY THẾ BẰNG ĐƯỜNG DẪN ẢNH CỦA BẠN
              imagePath: 'assets/images/cards/saved_outfits_bg.webp',
              onTap: () => ref.read(mainScreenIndexProvider.notifier).state = 2,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTodaysSuggestionCard(BuildContext context, WidgetRef ref, HomePageState state) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileProvider);
    final String backgroundImagePath = state.backgroundImagePath ?? 'assets/images/weather_backgrounds/default_1.webp';
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER SECTION =====
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: profileState.showWeatherImage
                      ? Image.asset(
                          backgroundImagePath,
                          key: ValueKey(backgroundImagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          profileState.showWeatherImage ? Colors.white : theme.colorScheme.surfaceContainerHighest,
                          profileState.showWeatherImage
                              ? Colors.white.withValues(alpha:0.0)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.0),
                        ],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.weather?['name'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  state.weather!['name'] as String,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            (state.weather != null
                              ? Row(
                                  children: [
                                    Icon(_getWeatherIcon(state.weather!['weather'][0]['icon'] as String), color: Colors.orange.shade700, size: 32),
                                    const SizedBox(width: 8),
                                    Text('${(state.weather!['main']['temp'] as num).toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : const SizedBox(height: 40, child: Center(child: Text("Weather data unavailable.")))
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (profileState.showWeatherImage)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                      icon: state.isRefreshingBackground
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                            )
                          : const Icon(Icons.refresh, color: Colors.black54),

                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha:0.5),
                        iconSize: 20,
                      ),
                      tooltip: 'Change background',

                      // <<< Vô hiệu hóa nút bấm khi đang refresh >>>
                      onPressed: state.isRefreshingBackground
                          ? null
                          : () {
                              ref.read(homeProvider.notifier).refreshBackgroundImage();
                            },
                    ),
                  ),
              ],
            ),
          ),
          
          // <<< Thêm ô nhập liệu và nút bấm mới >>>
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Căn lề phải cho bộ đếm
            children: [
              TextField(
                controller: _purposeController,
                maxLength: 150,
                maxLines: null, 
                decoration: InputDecoration(
                  hintText: 'Purpose? (e.g. coffee, date night...)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  counterText: "", // Quan trọng: Ẩn bộ đếm mặc định
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: state.isLoading 
                      ? null
                      : () {
                          final notifier = ref.read(homeProvider.notifier);
                          notifier.getNewSuggestion(purpose: _purposeController.text);
                          FocusScope.of(context).unfocus();
                      }
                  )
                ),
              ),
              // <<< BỘ ĐẾM MỚI CỦA CHÚNG TA >>>
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '$_currentPurposeLength/150',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                      ),
                ),
              ),
            ],
          ),
          // <<< KẾT THÚC THAY ĐỔI 3 >>>

          // ===== PHẦN 2: NỘI DUNG GỢI Ý (NỀN TRẮNG) =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: 
            state.isLoading
              ? const Center(heightFactor: 5, child: CircularProgressIndicator())
              : state.suggestionResult != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuggestionPlaceholder(state.suggestionResult!),
                    const SizedBox(height: 16),
                    Text(
                      state.suggestionResult!.outfitName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.suggestionResult!.reason,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit & Save'),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.outfitBuilder, arguments: state.suggestionResult);
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  heightFactor: 5,
                  child: Text(
                    state.errorMessage ?? 'Describe your purpose and tap the send button to get suggestions!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ),
          ),
          
          if (state.suggestionTimestamp != null && state.suggestionResult != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last updated: ${DateFormat('HH:mm, dd/MM/yyyy').format(state.suggestionTimestamp!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Các hàm còn lại (_buildSuggestionPlaceholder, _getWeatherIcon) giữ nguyên
  Widget _buildSuggestionPlaceholder(SuggestionResult result) {
    Widget singlePlaceholder(ClothingItem? item, {double? width, double? height}) {
      if (item == null) {
        return DottedBorder(
          options: RoundedRectDottedBorderOptions(
            // XÓA DÒNG BÁO LỖI "borderType: BorderType.RRect,"
            radius: const Radius.circular(8),
            color: Colors.grey.shade400,
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.error_outline),
      );
    }

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, bottom: 0, child: singlePlaceholder(result.composition['outerwear'])),
            Positioned(top: 20, left: 20, right: 20, height: 150, child: singlePlaceholder(result.composition['topwear'])),
            Positioned(bottom: 60, left: 40, right: 40, height: 180, child: singlePlaceholder(result.composition['bottomwear'])),
            Positioned(bottom: 10, left: 60, right: 60, height: 60, child: singlePlaceholder(result.composition['footwear'])),
            Positioned(top: 10, right: 10, width: 50, height: 50, child: singlePlaceholder(result.composition['accessories'])),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': case '01n': return Icons.wb_sunny;
      case '02d': case '02n': return Icons.cloud_outlined;
      case '03d': case '03n': case '04d': case '04n': return Icons.cloud;
      case '09d': case '09n': return Icons.grain;
      case '10d': case '10n': return Icons.water_drop;
      case '11d': case '11n': return Icons.thunderstorm;
      case '13d': case '13n': return Icons.ac_unit;
      case '50d': case '50n': return Icons.foggy;
      default: return Icons.thermostat;
    }
  }
}
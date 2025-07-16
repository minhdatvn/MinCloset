// lib/screens/pages/home_page.dart
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/services/unit_conversion_service.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/widgets/action_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:mincloset/widgets/weekly_planner.dart';
import 'package:showcaseview/showcaseview.dart';

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
  final TextEditingController _purposeController = TextEditingController();
  final FocusNode _purposeFocusNode = FocusNode();
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
    _purposeFocusNode.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final homeState = ref.watch(homeProvider);
  final l10n = context.l10n;

  return Scaffold(
    appBar: AppBar(
      title: _buildHeader(context, ref, l10n),
      toolbarHeight: 80,
    ),
    body: RefreshIndicator(
      onRefresh: () async => await ref.read(homeProvider.notifier).refreshWeatherOnly(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // *** THAY ĐỔI 1: Xóa thuộc tính `padding` ở đây ***
        // padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // *** THAY ĐỔI 2: Thêm Padding để bọc các phần tử phía trên ***
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionHub(context, ref, l10n),
                ],
              ),
            ),
            
            // *** THAY ĐỔI 3: Để `WeeklyPlanner` ra ngoài Padding ***
            const SizedBox(height: 32),
            WeeklyPlanner(l10n: l10n),
            const SizedBox(height: 32),

            // *** THAY ĐỔI 4: Thêm Padding cho các phần tử còn lại phía dưới ***
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.home_suggestionTitle,
                  ),
                  const SizedBox(height: 16),
                  _buildTodaysSuggestionCard(context, ref, homeState),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Các hàm build UI con không thay đổi, chỉ cần truyền ref nếu cần
  Widget _buildHeader(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final userName = ref.watch(profileProvider.select((state) => state.userName));
    final avatarPath = ref.watch(profileProvider.select((state) => state.avatarPath));

  return Row(
    children: [
      // 1. Bọc CircleAvatar trong InkWell để xử lý onTap riêng
      InkWell(
        onTap: () {
          // Chỉ cần gọi updateAvatar, không cần await hay làm gì thêm
          ref.read(mainScreenIndexProvider.notifier).state = 3;
        },
        customBorder: const CircleBorder(), // Giúp hiệu ứng ripple tròn
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
          child: avatarPath == null
              ? const Icon(Icons.person, size: 24, color: Colors.grey)
              : null,
        ),
      ),
      const SizedBox(width: 12),
      
      // 2. Cột Text giờ đây không còn nằm trong InkWell nữa
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              l10n.home_greeting,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              userName ?? l10n.home_userNameDefault,
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
        ],
      ),

      // Các thành phần còn lại giữ nguyên
      const Spacer(),
      IconButton(
          onPressed: () { /* TODO: Implement notifications */ },
          icon: const Icon(Icons.notifications_outlined, size: 28)),
    ],
  );
}

  Widget _buildActionHub(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Không còn SectionHeader "Action Hub" ở đây
        const SizedBox(height: 16), // Thêm khoảng cách trên cùng
        Row(
          children: [
            ActionCard(
              label: l10n.home_actionAddItem,
              icon: Icons.add_a_photo_outlined,
              onTap: () {
                ref.read(isAddItemMenuOpenProvider.notifier).state = true;
              },
            ),
            const SizedBox(width: 6),
            ActionCard(
              label: l10n.home_actionCreateCloset,
              icon: Icons.create_new_folder_outlined,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editCloset);
              },
            ),
            const SizedBox(width: 6),
            ActionCard(
              label: l10n.home_actionCreateOutfits,
              icon: Icons.design_services_outlined,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.outfitBuilder);
              },
            ),
            const SizedBox(width: 6),
            ActionCard(
              label: l10n.home_actionSavedOutfits,
              icon: Icons.collections_bookmark_outlined,
              onTap: () {
                ref.read(mainScreenIndexProvider.notifier).state = 2;
              },
            ),
          ],
        ),
      ],
    );
  }

  
  Widget _buildTodaysSuggestionCard(BuildContext context, WidgetRef ref, HomePageState state) {
  final theme = Theme.of(context);
  final profileState = ref.watch(profileProvider);
  final unitConverter = ref.watch(unitConversionServiceProvider);
  final String backgroundImagePath = state.backgroundImagePath ?? 'assets/images/weather_backgrounds/default_1.webp';
  final l10n = context.l10n;
  
  return Showcase(
      key: QuestHintKeys.getSuggestionHintKey,
      title: l10n.home_suggestionTitle,
      description: 'Describe your purpose for the day (e.g., "coffee with friends", "work meeting") and tap the send button to get a personalized outfit suggestion!',
      child: Card(
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
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Lớp 1: Ảnh nền (Không đổi)
                  if (profileState.showWeatherImage)
                    Image.asset(
                      backgroundImagePath,
                      key: ValueKey(backgroundImagePath),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),

                  // Lớp 2: Gradient nền trắng để hòa vào nội dung (KHÔI PHỤC LẠI)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withValues(alpha:0),
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                  
                  // Lớp 3: Nội dung (Nút Refresh và Thông tin thời tiết)
                  // Chúng ta sẽ đặt cả hai vào trong cùng một Stack con để quản lý
                  Stack(
                    children: [
                      if (profileState.showWeatherImage)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            iconSize: 20,
                            icon: state.isRefreshingBackground
                                ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                : const Icon(Icons.refresh, color: Colors.black54),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha:0.5),
                            ),
                            onPressed: state.isRefreshingBackground ? null : ref.read(homeProvider.notifier).refreshBackgroundImage,
                          ),
                        ),
                      
                      // Thông tin thời tiết được đặt trong Positioned như cũ
                      if (state.weather != null)
                        Positioned(
                          bottom: 4,
                          left: 16,
                          right: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                _getWeatherIcon(state.weather!['weather'][0]['icon'] as String),
                                color: Colors.orange.shade700, // << Đổi lại màu chữ và icon
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  state.weather!['name'] as String,
                                  style: const TextStyle(
                                    color: Colors.black87, // << Đổi lại màu chữ
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  unitConverter.formatTemperature(
                                    state.weather!['main']['temp'].toDouble(),
                                    profileState.tempUnit,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
            
            // <<< Thêm ô nhập liệu và nút bấm mới >>>
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Căn lề phải cho bộ đếm
              children: [
                TextField(
                  controller: _purposeController,
                  focusNode: _purposeFocusNode,
                  maxLength: 150,
                  maxLines: null, 
                  decoration: InputDecoration(
                    hintText: l10n.suggestion_purposeHint,
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    counterText: "", // Quan trọng: Ẩn bộ đếm mặc định
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: state.isLoading 
                        ? null
                        : () {
                            final notifier = ref.read(homeProvider.notifier);
                            notifier.getNewSuggestion(purpose: _purposeController.text);
                            _purposeFocusNode.unfocus(); 
                        }
                    )
                  ),
                ),
                // <<< BỘ ĐẾM MỚI CỦA CHÚNG TA >>>
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    l10n.suggestion_purposeLength(_currentPurposeLength, 150),
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
                          label: Text(l10n.suggestion_editAndSaveButton),
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
                      state.errorMessage ?? l10n.suggestion_placeholder,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                  ),
            ),
            
            if (state.suggestionTimestamp != null && state.suggestionResult != null) ...[
              if (state.weather == null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.suggestion_weatherUnavailable,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    l10n.suggestion_lastUpdated(DateFormat('HH:mm, dd/MM/yyyy').format(state.suggestionTimestamp!)),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ]
          ],
        ),
      )
    );
  }

  Widget _buildSuggestionPlaceholder(SuggestionResult result) {
    Widget singlePlaceholder(ClothingItem? item, {double? width, double? height}) {
      if (item == null) {
        return DottedBorder(
          options: RoundedRectDottedBorderOptions(
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
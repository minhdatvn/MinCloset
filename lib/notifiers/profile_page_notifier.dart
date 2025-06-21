// lib/notifiers/profile_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageNotifier extends StateNotifier<ProfilePageState> {
  final Ref _ref;

  ProfilePageNotifier(this._ref) : super(const ProfilePageState()) {
    // Tải dữ liệu lần đầu
    loadInitialData();

    // Lắng nghe tín hiệu để tự động tải lại
    _ref.listen<int>(itemAddedTriggerProvider, (previous, next) {
      if (previous != next) {
        loadInitialData();
      }
    });
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final closetRepo = _ref.read(closetRepositoryProvider);
      final itemRepo = _ref.read(clothingItemRepositoryProvider);
      final outfitRepo = _ref.read(outfitRepositoryProvider);

      final userName = prefs.getString('user_name') ?? 'Người dùng MinCloset';
      final avatarPath = prefs.getString('user_avatar_path');
      final cityModeString = prefs.getString('city_mode') ?? 'auto';
      // <<< SỬA ĐỔI: Dùng .byName để parse enum an toàn hơn >>>
      final cityMode = CityMode.values.byName(cityModeString);
      // <<< SỬA ĐỔI: Đọc tên hiển thị đầy đủ thay vì tên cũ >>>
      final manualCity = prefs.getString('manual_city_name') ?? 'Da Nang';

      final allItems = await itemRepo.getAllItems();
      final allClosets = await closetRepo.getClosets();
      final allOutfits = await outfitRepo.getOutfits();

      final colorDist = <String, int>{};
      final categoryDist = <String, int>{};
      final seasonDist = <String, int>{};
      final occasionDist = <String, int>{};

      for (final item in allItems) {
        final colors =
            item.color.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final color in colors) {
          colorDist[color] = (colorDist[color] ?? 0) + 1;
        }
        final mainCategory = item.category.split('>').first.trim();
        if (mainCategory.isNotEmpty) {
          categoryDist[mainCategory] = (categoryDist[mainCategory] ?? 0) + 1;
        }
        if (item.season != null && item.season!.isNotEmpty) {
          final seasons = item.season!.split(',').map((e) => e.trim());
          for (final season in seasons) {
            seasonDist[season] = (seasonDist[season] ?? 0) + 1;
          }
        }
        if (item.occasion != null && item.occasion!.isNotEmpty) {
          final occasions = item.occasion!.split(',').map((e) => e.trim());
          for (final occasion in occasions) {
            occasionDist[occasion] = (occasionDist[occasion] ?? 0) + 1;
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        userName: userName,
        avatarPath: avatarPath,
        cityMode: cityMode,
        manualCity: manualCity,
        totalItems: allItems.length,
        totalClosets: allClosets.length,
        totalOutfits: allOutfits.length,
        colorDistribution: colorDist,
        categoryDistribution: categoryDist,
        seasonDistribution: seasonDist,
        occasionDistribution: occasionDist,
      );
    } catch (e, s) {
      logger.e("Lỗi khi tải dữ liệu trang cá nhân", error: e, stackTrace: s);
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Không thể tải dữ liệu. Vui lòng thử lại.",
      );
    }
  }

  Future<void> updateUserName(String name) async {
    if (name.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.trim());
    state = state.copyWith(userName: name.trim());
  }

  Future<void> updateAvatar() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path', path);
      state = state.copyWith(avatarPath: path);
    }
  }

  // <<< THAY THẾ HOÀN TOÀN HÀM CŨ BẰNG HÀM NÀY >>>
  Future<void> updateCityPreference(
      CityMode mode, CitySuggestion? suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_mode', mode.name);

    if (mode == CityMode.manual && suggestion != null) {
      // Lưu tất cả thông tin cần thiết
      await prefs.setString('manual_city_name', suggestion.displayName);
      await prefs.setDouble('manual_city_lat', suggestion.lat);
      await prefs.setDouble('manual_city_lon', suggestion.lon);
      state =
          state.copyWith(cityMode: mode, manualCity: suggestion.displayName);
    } else {
      // Xóa các key cũ nếu chuyển sang chế độ auto
      await prefs.remove('manual_city_name');
      await prefs.remove('manual_city_lat');
      await prefs.remove('manual_city_lon');
      state = state.copyWith(cityMode: mode);
    }

    // Yêu cầu HomePage tải lại gợi ý với thành phố mới
    _ref.read(homeProvider.notifier).getNewSuggestion();
  }
}

final profileProvider =
    StateNotifierProvider.autoDispose<ProfilePageNotifier, ProfilePageState>(
        (ref) {
  return ProfilePageNotifier(ref);
});
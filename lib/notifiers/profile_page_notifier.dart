// lib/notifiers/profile_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/utils/logger.dart';

class ProfilePageNotifier extends StateNotifier<ProfilePageState> {
  final Ref _ref;
  
  ProfilePageNotifier(this._ref) : super(const ProfilePageState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    // Không cần set isLoading ở đây nữa vì state mặc định đã là true
    try {
      final prefs = await SharedPreferences.getInstance();
      final closetRepo = _ref.read(closetRepositoryProvider);
      final itemRepo = _ref.read(clothingItemRepositoryProvider);
      final outfitRepo = _ref.read(outfitRepositoryProvider);

      final userName = prefs.getString('user_name') ?? 'Người dùng MinCloset';
      final avatarPath = prefs.getString('user_avatar_path');
      final cityModeString = prefs.getString('city_mode') ?? 'auto';
      final cityMode = cityModeString == 'auto' ? CityMode.auto : CityMode.manual;
      final manualCity = prefs.getString('manual_city') ?? 'Da Nang';

      final allItems = await itemRepo.getAllItems();
      final allClosets = await closetRepo.getClosets();
      final allOutfits = await outfitRepo.getOutfits();

      final colorDist = <String, int>{};
      final categoryDist = <String, int>{};
      for (final item in allItems) {
        final colors = item.color.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final color in colors) {
          colorDist[color] = (colorDist[color] ?? 0) + 1;
        }
        final mainCategory = item.category.split('>').first.trim();
        categoryDist[mainCategory] = (categoryDist[mainCategory] ?? 0) + 1;
      }

      state = state.copyWith(
        isLoading: false, // <<< Tải xong, đặt isLoading=false
        userName: userName,
        avatarPath: avatarPath,
        cityMode: cityMode,
        manualCity: manualCity,
        totalItems: allItems.length,
        totalClosets: allClosets.length,
        totalOutfits: allOutfits.length,
        colorDistribution: colorDist,
        categoryDistribution: categoryDist,
      );
    } catch (e, s) {
      logger.e("Lỗi khi tải dữ liệu trang cá nhân", error: e, stackTrace: s);
      // <<< Cập nhật state với thông báo lỗi
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
      // Cập nhật state để UI build lại với ảnh mới
      state = state.copyWith(avatarPath: path);
    }
  }

  Future<void> updateCityPreference(CityMode mode, String? manualCity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_mode', mode == CityMode.auto ? 'auto' : 'manual');
    if (mode == CityMode.manual && manualCity != null) {
      await prefs.setString('manual_city', manualCity);
      state = state.copyWith(cityMode: mode, manualCity: manualCity);
    } else {
      state = state.copyWith(cityMode: mode);
    }
  }
}

final profileProvider = StateNotifierProvider.autoDispose<ProfilePageNotifier, ProfilePageState>((ref) {
  return ProfilePageNotifier(ref);
});
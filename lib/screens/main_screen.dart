// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart'; // <<< SỬA LỖI 1: Sửa tên file import
import 'package:mincloset/screens/pages/profile_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Hàm xử lý khi một icon được nhấn
  void _onItemTapped(int index) {
    // Chúng ta có 5 "điểm đến" nhưng chỉ 4 trang thực.
    // Nếu người dùng nhấn vào vị trí ở giữa (index 2), chúng ta sẽ không đổi trang.
    if (index == 2) {
      _showAddMenu();
      return;
    }

    // Ánh xạ index của destination sang index của trang
    // 0 -> 0 (Home)
    // 1 -> 1 (Closets)
    // 3 -> 2 (Outfits)
    // 4 -> 3 (Profile)
    int pageIndex = index > 2 ? index - 1 : index;
    ref.read(mainScreenIndexProvider.notifier).state = pageIndex;
  }

  // <<< SỬA LỖI 2: Mang logic hiển thị menu vào đây >>>
  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndAnalyzeImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from album (up to 10)'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndAnalyzeImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm này cũng được mang từ GlobalAddButton vào đây
  Future<void> _pickAndAnalyzeImages(ImageSource source) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final imagePicker = ImagePicker();

    List<XFile> pickedFiles = [];

    if (source == ImageSource.gallery) {
      pickedFiles = await imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
    } else {
      final singleFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (singleFile != null) {
        pickedFiles.add(singleFile);
      }
    }

    if (!mounted || pickedFiles.isEmpty) return;

    List<XFile> filesToProcess = pickedFiles;
    if (pickedFiles.length > 10) {
      filesToProcess = pickedFiles.take(10).toList();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Maximum of 10 photos selected. Extra photos were skipped.')),
      );
    }

    final itemsWereAdded = await navigator.pushNamed(
      AppRoutes.analysisLoading,
      arguments: filesToProcess,
    );

    if (itemsWereAdded == true) {
      ref.read(itemChangedTriggerProvider.notifier).state++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPageIndex = ref.watch(mainScreenIndexProvider);

    // Ánh xạ ngược từ page index sang destination index để highlight đúng
    int destinationIndex = selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedPageIndex,
        children: const <Widget>[
          HomePage(),
          ClosetsPage(),
          OutfitsHubPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 75,
        backgroundColor: Colors.white,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        selectedIndex: destinationIndex,
        onDestinationSelected: _onItemTapped,
        indicatorShape: const StadiumBorder(),
        destinations: [
          // Icon cho Home
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          
          // Icon cho Closets (bạn có thể thay đổi ở đây)
          const NavigationDestination(
            icon: Icon(Icons.door_sliding_outlined), // Thay đổi icon ở đây
            selectedIcon: Icon(Icons.door_sliding), // Và ở đây
            label: 'Closets',
          ),

          // ===== Sửa lỗi và Cập nhật cho nút "+" =====
          // Bọc trong GestureDetector để khôi phục tính năng
          GestureDetector(
            onTap: _showAddMenu, // Gọi hàm hiển thị menu khi nhấn
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white, // << Đổi màu nền thành trắng
                  border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: theme.colorScheme.primary, size: 32),
              ),
            ),
          ),
          
          // Icon cho Outfits (bạn có thể thay đổi ở đây)
          const NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined), // Thay đổi icon ở đây
            selectedIcon: Icon(Icons.collections_bookmark), // Và ở đây
            label: 'Outfits',
          ),

          // Icon cho Profile
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
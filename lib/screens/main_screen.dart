// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';

// BƯỚC 1: Chuyển MainScreen thành ConsumerStatefulWidget
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

// BƯỚC 2: Thêm "with SingleTickerProviderStateMixin" để quản lý animation
class _MainScreenState extends ConsumerState<MainScreen> with SingleTickerProviderStateMixin {
  // BƯỚC 3: Khai báo các biến trạng thái và animation
  late final AnimationController _animationController;
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  final List<Widget> _pages = const [
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  // BƯỚC 4: Logic đóng/mở menu và animation
  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    setState(() => _isMenuOpen = true);
    _animationController.forward();
    _overlayEntry = _buildMenuOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    setState(() => _isMenuOpen = false);
    _animationController.reverse();
    _removeOverlay();
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // BƯỚC 5: Widget xây dựng giao diện cho menu nổi (Overlay)
  OverlayEntry _buildMenuOverlay() {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    void performAction(ImageSource source) {
      _closeMenu();
      Future.delayed(const Duration(milliseconds: 100), () {
        _pickAndAnalyzeImages(source);
      });
    }

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _closeMenu,
          child: Material(
            color: Colors.black.withValues(alpha:0.5),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 85 + bottomPadding, // 75 (navbar) + 10 (margin)
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {},
                      child: FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Hình tam giác nhỏ
                              CustomPaint(
                                size: const Size(20, 10),
                                painter: TrianglePainter(color: theme.cardColor),
                              ),
                              // Nội dung menu
                              Container(
                                margin: const EdgeInsets.only(bottom: 10), // Để chỗ cho tam giác
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_camera_outlined),
                                      title: const Text('Take photo'),
                                      onTap: () => performAction(ImageSource.camera),
                                    ),
                                    const Divider(height: 1),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library_outlined),
                                      title: const Text('Choose from album (up to 10)'),
                                      onTap: () => performAction(ImageSource.gallery),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Logic điều hướng tab và xử lý ảnh (giữ nguyên, chỉ điều chỉnh lại)
  void _onItemTapped(int index) {
    if (index == 2) {
      _toggleMenu();
      return;
    }

    if (_isMenuOpen) {
      _closeMenu();
    }

    int pageIndex = index > 2 ? index - 1 : index;
    ref.read(mainScreenIndexProvider.notifier).state = pageIndex;
  }
  
  Future<void> _pickAndAnalyzeImages(ImageSource source) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final imagePicker = ImagePicker();

    List<XFile> pickedFiles = [];

    if (source == ImageSource.gallery) {
      pickedFiles = await imagePicker.pickMultiImage(maxWidth: 1024, imageQuality: 85);
    } else {
      final singleFile = await imagePicker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (singleFile != null) pickedFiles.add(singleFile);
    }

    if (!mounted || pickedFiles.isEmpty) return;

    List<XFile> filesToProcess = pickedFiles;
    if (pickedFiles.length > 10) {
      filesToProcess = pickedFiles.take(10).toList();
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Maximum of 10 photos selected. Extra photos were skipped.')));
    }

    final itemsWereAdded = await navigator.pushNamed(AppRoutes.analysisLoading, arguments: filesToProcess);

    if (itemsWereAdded == true) {
      ref.read(itemChangedTriggerProvider.notifier).state++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPageIndex = ref.watch(mainScreenIndexProvider);
    
    int destinationIndex = selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;
    if (_isMenuOpen) destinationIndex = 2;

    // BƯỚC 6: Bọc Scaffold bằng PopScope để xử lý nút back của hệ thống
    return PopScope(
      canPop: !_isMenuOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMenuOpen) {
          _closeMenu();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedPageIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          height: 75,
          selectedIndex: destinationIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.door_sliding_outlined), selectedIcon: Icon(Icons.door_sliding), label: 'Closets'),
            
            // BƯỚC 7: Cập nhật widget cho nút "Add" ở giữa
            NavigationDestination(
              icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.125).animate(_animationController),
                child: const Icon(Icons.add_circle),
              ),
              label: 'Add items',
            ),
            const NavigationDestination(icon: Icon(Icons.collections_bookmark_outlined), selectedIcon: Icon(Icons.collections_bookmark), label: 'Outfits'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// BƯỚC 8: Thêm class CustomPainter để vẽ hình tam giác
class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, size.height); // Đỉnh dưới cùng (ở giữa)
    path.lineTo(0, 0); // Đỉnh trái trên
    path.lineTo(size.width, 0); // Đỉnh phải trên
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
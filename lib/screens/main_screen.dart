// lib/screens/main_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:showcaseview/showcaseview.dart';

// <<< SỬA LỖI: Lớp MainScreen giờ là StatelessWidget và chỉ chứa ShowCaseWidget >>>
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ShowCaseWidget sẽ bọc MainScreenView, cung cấp context đúng cho tutorial
    return ShowCaseWidget(
      // Tham số builder nhận một hàm, không phải một widget Builder
      builder: (context) => const MainScreenView(),
    );
  }
}


// Toàn bộ logic và giao diện của màn hình được chuyển vào đây
class MainScreenView extends ConsumerStatefulWidget {
  const MainScreenView({super.key});

  @override
  ConsumerState<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends ConsumerState<MainScreenView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  final List<Widget> _pages = const [
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];

  final GlobalKey _addKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Context ở đây đã đúng và có thể tìm thấy ShowCaseWidget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([_addKey]);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  // Các hàm logic khác không có gì thay đổi...
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
        _overlayEntry = _buildMenuOverlay();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _animationController.reverse();
        _removeOverlay();
      }
    });
  }
  
  void _closeMenu() {
    if (_isMenuOpen) {
      _toggleMenu();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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
                    bottom: 85 + bottomPadding,
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
                              CustomPaint(
                                size: const Size(20, 10),
                                painter: TrianglePainter(color: theme.cardTheme.color ?? Colors.white),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color ?? Colors.white,
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
                                      title: const Text('From album (up to 10)'),
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
    final imagePicker = ImagePicker();

    if (source == ImageSource.gallery) {
      final pickedFiles = await imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty && mounted) {
        navigator.pushNamed(AppRoutes.analysisLoading, arguments: pickedFiles);
      }
      return;
    }
    
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;
    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    final editedBytes = await navigator.pushNamed<Uint8List?>(
      AppRoutes.imageEditor,
      arguments: imageBytes,
    );
    
    if (editedBytes != null && mounted) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = await File(tempPath).writeAsBytes(editedBytes);
      final editedXFile = XFile(tempFile.path);

      if (mounted) {
        navigator.pushNamed(AppRoutes.analysisLoading, arguments: [editedXFile]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPageIndex = ref.watch(mainScreenIndexProvider);
    
    int destinationIndex = selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;
    if (_isMenuOpen) destinationIndex = 2;

    final navBarTheme = theme.navigationBarTheme;
    final Set<WidgetState> states = _isMenuOpen ? {WidgetState.selected} : {};
    final labelStyle = navBarTheme.labelTextStyle?.resolve(states);
    final iconColor = navBarTheme.iconTheme?.resolve(states)?.color;

    return PopScope(
      canPop: !_isMenuOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMenuOpen) {
          _closeMenu();
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          bottom: true,
          child: IndexedStack(
            index: selectedPageIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: destinationIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.door_sliding_outlined), selectedIcon: Icon(Icons.door_sliding), label: 'Closets'),
            
            Showcase(
              key: _addKey,
              title: 'Add Item',
              description: 'Let\'s start by adding your first item to the closet!',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9.5),
                child: GestureDetector(
                  onTap: _toggleMenu,
                  behavior: HitTestBehavior.opaque,
                  child: Tooltip(
                    message: "Add item",
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: _isMenuOpen 
                              ? Icon(
                                  Icons.cancel,
                                  key: const ValueKey('cancel_icon'),
                                  size: 45,
                                  color: iconColor, 
                                )
                              : Icon(
                                  Icons.add_circle_outline,
                                  key: const ValueKey('add_icon'),
                                  size: 45,
                                  color: iconColor, 
                                ),
                          ),
                        Text('Add items', style: labelStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const NavigationDestination(icon: Icon(Icons.collections_bookmark_outlined), selectedIcon: Icon(Icons.collections_bookmark), label: 'Outfits'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
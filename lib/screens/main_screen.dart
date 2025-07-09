// lib/screens/main_screen.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/quest_fab_notifier.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/states/tutorial_state.dart';
import 'package:mincloset/widgets/quest_mascot.dart';
import 'package:mincloset/widgets/speech_bubble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MainScreenView();
  }
}

class MainScreenView extends ConsumerStatefulWidget {
  const MainScreenView({super.key});

  @override
  ConsumerState<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends ConsumerState<MainScreenView>
    with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(tutorialProvider.notifier).startTutorial();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  // Các hàm tiện ích (_toggleMenu, _closeMenu, v.v.) giữ nguyên
  void _toggleMenu() {
    if (ref.read(tutorialProvider).isActive) return;
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
            color: Colors.black.withOpacity(0.5),
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
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.1), end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.easeOut)),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              CustomPaint(
                                size: const Size(20, 10),
                                painter: TrianglePainter(
                                    color: theme.cardTheme.color ?? Colors.white),
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
                                      leading: const Icon(
                                          Icons.photo_camera_outlined),
                                      title: const Text('Take photo'),
                                      onTap: () =>
                                          performAction(ImageSource.camera),
                                    ),
                                    const Divider(height: 1),
                                    ListTile(
                                      leading: const Icon(
                                          Icons.photo_library_outlined),
                                      title: const Text('From album (up to 10)'),
                                      onTap: () =>
                                          performAction(ImageSource.gallery),
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
    if (ref.read(tutorialProvider).isActive) return;

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
        navigator.pushNamed(AppRoutes.analysisLoading,
            arguments: pickedFiles);
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
      final tempPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = await File(tempPath).writeAsBytes(editedBytes);
      final editedXFile = XFile(tempFile.path);

      if (mounted) {
        navigator.pushNamed(AppRoutes.analysisLoading,
            arguments: [editedXFile]);
      }
    }
  }

  final GlobalKey _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi state của tutorial
    ref.listen<TutorialState>(tutorialProvider, (previous, next) {
      if (!mounted) return;

      // Gỡ bỏ overlay tùy chỉnh nếu có
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }

      // Hiển thị overlay tùy chỉnh cho các bước welcome và introduce
      if (next.isActive && (next.currentStep == TutorialStep.welcome || next.currentStep == TutorialStep.introduce)) {
        _overlayEntry = _buildCustomTutorialOverlay(next.currentStep);
        Overlay.of(context).insert(_overlayEntry!);
      }
      // Khi đến bước showAddItem, bắt đầu showcase
      else if (next.isActive && next.currentStep == TutorialStep.showAddItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Lấy context hợp lệ từ GlobalKey của Scaffold
          final showcaseContext = _scaffoldKey.currentContext;
          if (mounted && showcaseContext != null) {
            ShowCaseWidget.of(showcaseContext).startShowCase([_addKey]);
          }
        });
      }
    });

    // Các logic khác giữ nguyên
    final mascotState = ref.watch(questMascotProvider);
    final selectedPageIndex = ref.watch(mainScreenIndexProvider);

    if (mascotState.position == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final size = MediaQuery.of(context).size;
        const mascotWidth = 80.0;
        const rightPadding = 16.0;
        final dx = size.width - mascotWidth - rightPadding;
        const dy = 450.0;
        ref.read(questMascotProvider.notifier).updatePosition(Offset(dx, dy));
      });
    }

    int destinationIndex =
        selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;
    if (_isMenuOpen) destinationIndex = 2;

    final theme = Theme.of(context);
    final navBarTheme = theme.navigationBarTheme;
    final Set<WidgetState> states = _isMenuOpen ? {WidgetState.selected} : {};
    final labelStyle = navBarTheme.labelTextStyle?.resolve(states);
    final iconColor = navBarTheme.iconTheme?.resolve(states)?.color;

    return ShowCaseWidget(
      onComplete: (index, key) {
        ref.read(tutorialProvider.notifier).dismissTutorial();
      },
      builder: (context) => PopScope(
        canPop: !_isMenuOpen,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _isMenuOpen) {
            _closeMenu();
          }
        },
        // Gán key cho Scaffold tại đây
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              SafeArea(
                top: false,
                bottom: true,
                child: IndexedStack(
                  index: selectedPageIndex,
                  children: _pages,
                ),
              ),
              if (mascotState.isVisible && mascotState.position != null)
                const QuestMascot(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: destinationIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              const NavigationDestination(
                  icon: Icon(Icons.door_sliding_outlined),
                  selectedIcon: Icon(Icons.door_sliding),
                  label: 'Closets'),
              
              Showcase.withWidget(
                key: _addKey,
                height: 200,
                width: MediaQuery.of(context).size.width * 0.8,
                container: GestureDetector(
                  onTap: () {
                    // Lấy context hợp lệ từ builder của chính GestureDetector
                    final showcaseContext = context; 
                    
                    // 1. Gọi dismiss() để ẩn giao diện của showcase
                    ShowCaseWidget.of(showcaseContext).dismiss();
                    
                    // 2. Trực tiếp gọi notifier để kết thúc trạng thái tutorial
                    ref.read(tutorialProvider.notifier).dismissTutorial();
                  },
                  child: SpeechBubble(
                    text: "Let's start by adding your first item to the closet!",
                    child: Image.asset(
                      'assets/images/mascot.webp',
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flutter_dash, size: 120, color: Colors.blue),
                    ),
                  ),
                ),
                disableDefaultTargetGestures: true,
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
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
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
              const NavigationDestination(
                  icon: Icon(Icons.collections_bookmark_outlined),
                  selectedIcon: Icon(Icons.collections_bookmark),
                  label: 'Outfits'),
              const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _buildCustomTutorialOverlay(TutorialStep currentStep) {
    return OverlayEntry(
      builder: (context) {
        String bubbleText = '';
        switch (currentStep) {
          case TutorialStep.welcome:
            bubbleText = "Welcome to MinCloset! I'm your personal fashion assistant.";
            break;
          case TutorialStep.introduce:
            bubbleText = "Let me introduce you to the first and most important feature!";
            break;
          default:
            return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => ref.read(tutorialProvider.notifier).nextStep(context),
          child: Material(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: SpeechBubble(
                text: bubbleText,
                child: Image.asset(
                  'assets/images/mascot.webp',
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.flutter_dash, size: 120, color: Colors.blue),
                ),
              ),
            ),
          ),
        );
      },
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
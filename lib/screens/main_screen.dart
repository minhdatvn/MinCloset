// lib/screens/main_screen.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/states/tutorial_state.dart';
import 'package:mincloset/widgets/speech_bubble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ShowCaseWidget(
      onFinish: () {
        // Gọi đến hàm trong tutorialProvider như cũ
        ref.read(tutorialProvider.notifier).dismissTutorial();
        
        // Gọi đến hàm mới để xử lý toàn bộ logic của mascot
        ref.read(questMascotProvider.notifier).finishTutorialAndShowMascot();
      },
      builder: (context) => const MainScreenView(),
    );
  }
}

class _MainScreenViewState extends ConsumerState<MainScreenView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late OverlayEntry? _menuOverlay;
  bool _isMenuOpen = false;

  final List<Widget> _pages = const [
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];

  final GlobalKey _welcomeKey = GlobalKey();
  final GlobalKey _introduceKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuOverlay = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance(); // Đọc trạng thái từ SharedPreferences
      final bool hasCompletedTutorial = prefs.getBool('has_completed_tutorial') ?? false;
      // Chỉ bắt đầu hướng dẫn nếu chưa hoàn thành
      if (!hasCompletedTutorial && mounted) {
        ShowCaseWidget.of(context).startShowCase([_welcomeKey, _introduceKey, _addKey]);
        ref.read(tutorialProvider.notifier).startTutorial();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeMenuOverlay();
    super.dispose();
  }
  
  void _removeMenuOverlay() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  void _toggleMenu() {
    if (ref.read(tutorialProvider).isActive) return;
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
        _menuOverlay = _buildMenuOverlay();
        Overlay.of(context).insert(_menuOverlay!);
      } else {
        _animationController.reverse();
        _removeMenuOverlay();
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
    final l10n = context.l10n;
    
    void performAction(ImageSource source) {
      _closeMenu();
      Future.delayed(const Duration(milliseconds: 100), () {
        _pickAndAnalyzeImages(source);
      });
    }

    _menuOverlay = OverlayEntry(
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
                                      title: Text(l10n.mainScreen_addItem_takePhoto),
                                      onTap: () => performAction(ImageSource.camera),
                                    ),
                                    const Divider(height: 1),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library_outlined),
                                      title: Text(l10n.mainScreen_addItem_fromAlbum),
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
    return _menuOverlay!;
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
      final pickedFiles = await imagePicker.pickMultiImage(maxWidth: 1024, imageQuality: 85);
      if (pickedFiles.isNotEmpty && mounted) {
        navigator.pushNamed(AppRoutes.analysisLoading, arguments: pickedFiles);
      }
      return;
    }

    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 1024, imageQuality: 85);

    if (pickedFile == null) return;
    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    final editedBytes = await navigator.pushNamed<Uint8List?>(AppRoutes.imageEditor, arguments: imageBytes);

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
  
  Widget _buildMascotContainer(BuildContext context, {required TutorialStep forStep}) {
    final l10n = context.l10n;
    String bubbleText;
    switch (forStep) {
      case TutorialStep.welcome:
        bubbleText = l10n.mainScreen_tutorial_welcome;
        break;
      case TutorialStep.introduce:
        bubbleText = l10n.mainScreen_tutorial_introduce;
        break;
      case TutorialStep.showAddItem:
        bubbleText = l10n.mainScreen_tutorial_showAddItem;
        break;
      default:
        return const SizedBox.shrink();
    }

    return GestureDetector(
      // THAY ĐỔI 3: Đơn giản hóa logic onTap.
      // Giờ đây nó chỉ có nhiệm vụ chuyển sang bước tiếp theo.
      // Việc kết thúc luồng đã được onFinish xử lý.
      onTap: () {
        ShowCaseWidget.of(context).next();
      },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<QuestHintState?>(questHintProvider, (previous, next) {
      // Nếu có tín hiệu mới (next != null), có key để gợi ý, và không phải là điều hướng qua routeName
      if (next != null && next.hintKey != null && next.routeName == null) {
        // Đợi UI build xong frame tiếp theo (sau khi đã chuyển tab)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Bắt đầu hiển thị showcase cho key được chỉ định
            ShowCaseWidget.of(context).startShowCase([next.hintKey!]);
            // Xóa tín hiệu đi để không bị gọi lại
            ref.read(questHintProvider.notifier).clearHint();
          }
        });
      }
    });

    final selectedPageIndex = ref.watch(mainScreenIndexProvider);
    final l10n = context.l10n;

    int destinationIndex = selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;
    if (_isMenuOpen) destinationIndex = 2;

    final theme = Theme.of(context);
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
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Showcase.withWidget(
                      key: _welcomeKey,
                      height: 250,
                      width: MediaQuery.of(context).size.width * 0.7,
                      targetShapeBorder: const CircleBorder(),
                      container: _buildMascotContainer(context, forStep: TutorialStep.welcome),
                      child: const SizedBox(width: 1, height: 1),
                     ),
                      Showcase.withWidget(
                      key: _introduceKey,
                      height: 250,
                      width: MediaQuery.of(context).size.width * 0.7,
                      targetShapeBorder: const CircleBorder(),
                      container: _buildMascotContainer(context, forStep: TutorialStep.introduce),
                      child: const SizedBox(width: 1, height: 1),
                     ),
                  ],
                ),
              ),
              // QuestMascot đã được chuyển ra GlobalUiScope, nên ta xóa nó ở đây.
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: destinationIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.mainScreen_bottomNav_home),
              NavigationDestination(
                  icon: const Icon(Icons.door_sliding_outlined),
                  selectedIcon: const Icon(Icons.door_sliding),
                  label: l10n.mainScreen_bottomNav_closets),
              Showcase(
                key: QuestHintKeys.addItemHintKey,
                title: l10n.mainScreen_hint_addItem,
                description: l10n.mainScreen_hint_addItem_description,
                child: Showcase.withWidget(
                  key: _addKey,
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.7,
                  container: _buildMascotContainer(context, forStep: TutorialStep.showAddItem),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 9.5),
                    child: GestureDetector(
                      onTap: _toggleMenu,
                      behavior: HitTestBehavior.opaque,
                      child: Tooltip(
                        message: l10n.mainScreen_bottomNav_addItems,
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
                            Text(l10n.mainScreen_bottomNav_addItems, style: labelStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              NavigationDestination(
                  icon: Icon(Icons.collections_bookmark_outlined),
                  selectedIcon: Icon(Icons.collections_bookmark),
                  label: l10n.mainScreen_bottomNav_outfits),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: l10n.mainScreen_bottomNav_profile),
            ],
          ),
        ),
      );
  }
}

// Widget MainScreenView không đổi
class MainScreenView extends ConsumerStatefulWidget {
  const MainScreenView({super.key});

  @override
  ConsumerState<MainScreenView> createState() => _MainScreenViewState();
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
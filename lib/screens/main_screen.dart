// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/states/tutorial_state.dart';
import 'package:mincloset/widgets/speech_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ShowCaseWidget(
      onFinish: () {
        // Gọi đến hàm trong tutorialProvider như cũ
        ref.read(tutorialProvider.notifier).dismissTutorial();
        
        // Gọi đến hàm mới để xử lý toàn bộ logic của mascot
        ref.read(questMascotProvider.notifier).finishTutorialAndShowMascot(l10n: l10n);
      },
      builder: (context) => const MainScreenView(),
    );
  }
}

class _MainScreenViewState extends ConsumerState<MainScreenView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  OverlayEntry? _menuOverlay;

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
    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedTutorial = prefs.getBool('has_completed_tutorial') ?? false;
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
    final currentState = ref.read(isAddItemMenuOpenProvider);
    ref.read(isAddItemMenuOpenProvider.notifier).state = !currentState;
  }

  void _closeMenu() {
    if (ref.read(isAddItemMenuOpenProvider)) {
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
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.analysisLoading,
              arguments: source);
        }
      });
    }

    _menuOverlay = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _closeMenu,
          child: Material(
            color: Colors.black.withValues(alpha: 0.5), // Đã sửa lỗi withValues
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

    // Nếu nhấn vào nút "Add items" (index 2)
    if (index == 2) {
      ref.read(isAddItemMenuOpenProvider.notifier).state = true; // Chỉ mở menu
      return; // Không làm gì khác, không thay đổi trang chính
    }

    // Đóng menu nếu nó đang mở và người dùng chọn tab khác
    if (ref.read(isAddItemMenuOpenProvider)) {
      ref.read(isAddItemMenuOpenProvider.notifier).state = false;
    }

    // Logic thay đổi chỉ mục trang chính
    int pageIndex = index;
    if (index > 2) { // Nếu index từ NavigationBar lớn hơn 2 (tức là Outfits hoặc Profile)
      pageIndex = index - 1; // Giảm đi 1 để bỏ qua vị trí của nút Add items ảo
    }
    ref.read(mainScreenIndexProvider.notifier).state = pageIndex;
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
    ref.listen<bool>(isAddItemMenuOpenProvider, (previous, isOpen) {
      if (isOpen) {
        _animationController.forward();
        _menuOverlay = _buildMenuOverlay();
        if (mounted) { // Chỉ cần kiểm tra mounted là đủ an toàn
          Overlay.of(context, rootOverlay: true).insert(_menuOverlay!);
        }
      } else {
        _animationController.reverse();
        _removeMenuOverlay();
      }
    });
    ref.listen<QuestHintState?>(questHintProvider, (previous, next) {
      if (next != null && next.hintKey != null && next.routeName == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ShowCaseWidget.of(context).startShowCase([next.hintKey!]);
            ref.read(questHintProvider.notifier).clearHint();
          }
        });
      }
    });

    final selectedPageIndex = ref.watch(mainScreenIndexProvider);
    final l10n = context.l10n;

    // Các biến này phải nằm trong phương thức build để có thể được truy cập
    final theme = Theme.of(context);
    final navBarTheme = theme.navigationBarTheme;
    final Set<WidgetState> states = ref.watch(isAddItemMenuOpenProvider) ? {WidgetState.selected} : {};
    final labelStyle = navBarTheme.labelTextStyle?.resolve(states);
    final iconColor = navBarTheme.iconTheme?.resolve(states)?.color;

    // Bắt đầu từ đây, đoạn code bạn cung cấp sẽ nằm trong build method
    int destinationIndex = selectedPageIndex >= 2 ? selectedPageIndex + 1 : selectedPageIndex;
    if (ref.watch(isAddItemMenuOpenProvider)) destinationIndex = 2; // Đã sửa lỗi _isMenuOpen

    return PopScope(
        canPop: !ref.watch(isAddItemMenuOpenProvider), // Đã sửa lỗi _isMenuOpen
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && ref.watch(isAddItemMenuOpenProvider)) { // Đã sửa lỗi _isMenuOpen
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
                              child: ref.watch(isAddItemMenuOpenProvider) // Đã sửa lỗi _isMenuOpen
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
// lib/screens/onboarding_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/auth_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/flow_providers.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;
  bool _isSigningIn = false;

  /// Hàm cuối cùng, đánh dấu onboarding hoàn thành và điều hướng
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      ref.read(onboardingCompletedProvider.notifier).state = true;
    }
  }

  /// Xử lý khi người dùng chọn luồng ẩn danh (nhập tên)
  Future<void> _completeOnboardingAnonymously() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Lưu tên người dùng nhập vào
      await ref
          .read(profileProvider.notifier)
          .updateProfileInfo({'name': _nameController.text.trim()});
      
      // Hoàn tất
      await _finishOnboarding();
    }
  }

  /// Xử lý khi người dùng chọn đăng nhập với Google
  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    final authRepository = ref.read(authRepositoryProvider);
    final User? user = await authRepository.signInWithGoogle();

    // Thêm kiểm tra `mounted` ở đây để đảm bảo an toàn sau `await`
    if (!mounted) {
      // Không cần setState vì widget đã bị hủy
      return;
    }

    if (user != null) {
      await ref
          .read(profileProvider.notifier)
          .updateProfileInfo({'name': user.displayName ?? 'New User'});

      final backupDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Thêm một kiểm tra `mounted` nữa
      if (backupDoc.exists && mounted) {
        final bool? shouldRestore = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Backup Found"),
            content: const Text("We found backed up data for this account. Would you like to restore it?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Start Fresh"),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Restore"),
              ),
            ],
          ),
        );

        // Thêm một kiểm tra `mounted` nữa sau khi dialog đóng lại
        if (shouldRestore == true && mounted) {
          // SỬA LỖI CÚ PHÁP: Truyền `context` như một tham số vị trí
          showAnimatedDialog(
            context, // <- SỬA Ở ĐÂY
            barrierDismissible: false,
            builder: (ctx) => const PopScope(
              canPop: false,
              child: AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 24),
                    Text("Restoring data..."),
                  ],
                ),
              ),
            ),
          );

          try {
            await ref.read(restoreServiceProvider).performRestore();

            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // Đóng dialog loading
              ref.read(notificationServiceProvider).showBanner(
                    message: "Data restored successfully!",
                    type: NotificationType.success,
                  );
              ref.read(itemChangedTriggerProvider.notifier).state++;
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // Đóng dialog loading
              ref.read(notificationServiceProvider).showBanner(
                    message: "Restore failed: ${e.toString()}",
                  );
            }
          }
        }
      }
      
      // Hoàn tất onboarding, cần kiểm tra `mounted` lần cuối
      if (mounted) {
        await _finishOnboarding();
      }

    } else {
      logger.i("User cancelled Google Sign-In.");
      setState(() => _isSigningIn = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      _buildPage(
        context,
        index: 0,
        imagePath: 'assets/images/onboarding/onboarding_p1.webp',
        title: l10n.onboarding_page1_title,
        subtitle: l10n.onboarding_page1_subtitle,
        description: l10n.onboarding_page1_description,
      ),
      _buildPage(
        context,
        index: 1,
        imagePath: 'assets/images/onboarding/onboarding_p2.webp',
        title: l10n.onboarding_page2_title,
        description: '',
        isFeatureList: true,
      ),
      _buildNamePage(context),
    ];

    return PageScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
          _buildBottomControls(context, pages.length),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context,
      {required int index,
      required String imagePath,
      required String title,
      String? subtitle,
      required String description,
      bool isFeatureList = false}) {
    final theme = Theme.of(context);
    if (index == 0 || index == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withValues(alpha:1), Colors.white.withValues(alpha:0.0)],
                stops: const [0.0, 0.4, 1.0],
                begin: Alignment.bottomCenter,
                end: const Alignment(0.0, -1.0 / 3.0),
              ),
            ),
          ),
          Positioned(
            bottom: index == 0 ? 120 : 40, 
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                ],
                const SizedBox(height: 16),
                if (isFeatureList) _buildFeatureList(context)
                else Text(description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
              ],
            ),
          )
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 200, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 150)),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
          ],
          const SizedBox(height: 16),
          Text(description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  // Widget for the final name input page, with Google Sign-In
  Widget _buildNamePage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n; // l10n cho các phần đã có sẵn
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mascot.webp', height: 150),
          const SizedBox(height: 24),
          Text(l10n.onboarding_page3_title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(l10n.onboarding_page3_subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: l10n.onboarding_page3_nameHint,
                border: InputBorder.none,
              ),
              validator: (value) {
                if (!_isSigningIn && (value == null || value.trim().isEmpty)) {
                  return l10n.onboarding_page3_nameValidator;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text("OR"), // Tiếng Anh mặc định
          const SizedBox(height: 24),
          _isSigningIn
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                  label: const Text('Sign in with Google'), // Tiếng Anh mặc định
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
        ],
      ),
    );
  }

  // Bottom controls
  Widget _buildBottomControls(BuildContext context, int pageCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(color: _currentPage == index ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          _buildLanguageSelector(context),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < pageCount - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              } else {
                _completeOnboardingAnonymously();
              }
            },
            style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
            child: _currentPage < pageCount - 1 ? const Icon(Icons.arrow_forward_ios) : const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  // Feature list helper
  Widget _buildFeatureList(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _featureItem(context, Icons.camera_alt_outlined, l10n.onboarding_page2_feature1_title, l10n.onboarding_page2_feature1_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.lightbulb_outline, l10n.onboarding_page2_feature2_title, l10n.onboarding_page2_feature2_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.brush_outlined, l10n.onboarding_page2_feature3_title, l10n.onboarding_page2_feature3_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.calendar_today_outlined, l10n.onboarding_page2_feature4_title, l10n.onboarding_page2_feature4_desc),
      ],
    );
  }

  Widget _featureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        )
      ],
    );
  }
  
  // Language selector helper
  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);
        return PopupMenuButton<Locale>(
          onSelected: (Locale newLocale) => ref.read(localeProvider.notifier).setLocale(newLocale.languageCode),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentLocale.languageCode == 'en' ? 'English' : 'Tiếng Việt', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                const Icon(Icons.arrow_drop_down, size: 20.0),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            const PopupMenuItem<Locale>(value: Locale('en'), child: Text('English')),
            const PopupMenuItem<Locale>(value: Locale('vi'), child: Text('Tiếng Việt')),
          ],
        );
      },
    );
  }
}
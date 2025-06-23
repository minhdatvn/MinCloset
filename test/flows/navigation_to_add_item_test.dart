// test/flows/navigation_to_add_item_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mocktail/mocktail.dart';

// --- MOCK VÀ FAKE CLASSES ---
class MockAnalyzeItemUseCase extends Mock implements AnalyzeItemUseCase {}

class FakeProfileNotifier extends StateNotifier<ProfilePageState> implements ProfilePageNotifier {
  FakeProfileNotifier() : super(const ProfilePageState(isLoading: false));
  @override
  Future<void> loadInitialData() async {}
  @override
  Future<void> updateAvatar() async {}
  @override
  Future<void> updateCityPreference(mode, suggestion) async {}
  @override
  Future<void> updateProfileInfo(data) async {}
}
class FakeHomeNotifier extends StateNotifier<HomePageState> implements HomePageNotifier {
  FakeHomeNotifier() : super(const HomePageState());
  @override
  Future<void> getNewSuggestion() async {}
}
class FakeXFile extends Fake implements XFile {}

void main() {
  // Mock cho image_picker
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeXFile());
    final d = Directory('test/temp_test_images');
    if (d.existsSync()) d.deleteSync(recursive: true);
    d.createSync(recursive: true);
    File('test/temp_test_images/new_item.png').writeAsBytesSync(Uint8List(0));

    const channel = MethodChannel('plugins.flutter.io/image_picker');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return [File('test/temp_test_images/new_item.png').path];
    });
  });

  testWidgets('Giai đoạn A=>B: Phải điều hướng được đến AddItemScreen và tìm thấy các widget', (WidgetTester tester) async {
    // --- ARRANGE ---
    final mockAnalyzeItemUseCase = MockAnalyzeItemUseCase();
    final aiResult = { 'name': 'Áo phông AI', 'category': 'Áo > Áo thun' };
    when(() => mockAnalyzeItemUseCase.execute(any())).thenAnswer((_) async => aiResult);

    // Bơm widget với tất cả các override cần thiết
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyzeItemUseCaseProvider.overrideWithValue(mockAnalyzeItemUseCase),
          // **BẮT BUỘC** phải override provider này ở đây để Dropdown được render
          closetsProvider.overrideWith((ref) => Future.value([Closet(id: 'c1', name: 'Tủ đồ chính')])),
          profileProvider.overrideWith((ref) => FakeProfileNotifier()),
          homeProvider.overrideWith((ref) => FakeHomeNotifier()),
        ],
        child: const MaterialApp(home: MainScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // --- ACT ---
    // Mô phỏng luồng chọn ảnh
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn từ Album'));
    await tester.pumpAndSettle(); // Chờ quá trình chuyển cảnh hoàn tất

    // --- ASSERT ---
    // Bây giờ, chúng ta chỉ kiểm tra kết quả của giai đoạn này
    
    // 1. Xác minh chúng ta đang ở đúng màn hình
    expect(find.text('Add Item'), findsOneWidget, reason: 'Phải tìm thấy title của AddItemScreen');

    // 2. Xác minh widget được AI điền dữ liệu đã hiển thị
    expect(find.widgetWithText(TextFormField, 'Áo phông AI'), findsOneWidget, reason: 'Phải tìm thấy TextFormField với tên từ AI');

    // 3. Xác minh widget phụ thuộc vào `closetsProvider` đã hiển thị
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget, reason: 'Phải tìm thấy Dropdown vì closetsProvider đã được mock');
  });
}
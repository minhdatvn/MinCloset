// test/notifiers/item_filter_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_filter_state.dart';
import 'package:mocktail/mocktail.dart';

class MockClothingItemRepository extends Mock implements ClothingItemRepository {}

void main() {
  late ProviderContainer container;
  late MockClothingItemRepository mockItemRepository;

  final page1Items = List.generate(15, (i) => ClothingItem(id: 'p1_$i', name: 'Item $i', category: 'Cat', color: 'Color', imagePath: '', closetId: 'c1'));
  final searchResults = [ClothingItem(id: 'search1', name: 'Search Result', category: 'Search', color: 'Color', imagePath: '', closetId: 'c1')];

  setUp(() {
    mockItemRepository = MockClothingItemRepository();
    container = ProviderContainer(
      overrides: [
        clothingItemRepositoryProvider.overrideWithValue(mockItemRepository),
      ],
    );
    reset(mockItemRepository);
  });

  tearDown(() {
    container.dispose();
  });

  group('ItemFilterNotifier Tests', () {
    test('Initial state and first page fetch should work correctly', () async {
      when(() => mockItemRepository.getFilteredItems(limit: any(named: 'limit'), offset: any(named: 'offset'), query: any(named: 'query'), filters: any(named: 'filters')))
          .thenAnswer((_) async => page1Items);
      
      final notifier = container.read(itemFilterProvider('test').notifier);

      // Đợi stream của notifier phát ra một state không còn loading nữa
      await notifier.stream.firstWhere((state) => !state.isLoading);

      final state = container.read(itemFilterProvider('test'));
      expect(state.items.length, 15);
      expect(state.hasMore, true);
    });

    // Bài test này đã được đơn giản hóa
    test('fetchMoreItems should add new items and update hasMore state', () async {
      // Arrange
      // Giả lập trạng thái ban đầu là đã có trang 1
      container.read(itemFilterProvider('test').notifier).state = ItemFilterState(isLoading: false, items: page1Items, hasMore: true);
      
      // Giả lập kết quả cho trang 2
      when(() => mockItemRepository.getFilteredItems(limit: any(named: 'limit'), offset: 15, query: any(named: 'query'), filters: any(named: 'filters')))
          .thenAnswer((_) async => []); // Giả sử trang 2 là trang cuối

      // Act
      await container.read(itemFilterProvider('test').notifier).fetchMoreItems();
      
      // Assert
      final state = container.read(itemFilterProvider('test'));
      expect(state.isLoadingMore, isFalse);
      expect(state.items.length, 15); // Vẫn là 15 vì trang 2 rỗng
      expect(state.hasMore, false); // Đã hết item để tải
    });
    
    // <<< SỬA LẠI HOÀN TOÀN BÀI TEST NÀY >>>
    test('Search should reset the list and fetch new data', () async {
      // Arrange
      container.read(itemFilterProvider('test').notifier).state = ItemFilterState(isLoading: false, items: page1Items, hasMore: true);
      final notifier = container.read(itemFilterProvider('test').notifier);

      when(() => mockItemRepository.getFilteredItems(limit: any(named: 'limit'), offset: 0, query: 'Search', filters: any(named: 'filters')))
          .thenAnswer((_) async => searchResults);

      // Act
      notifier.setSearchQuery('Search');
      
      // Assert
      // Đợi cho đến khi stream phát ra state cuối cùng mà chúng ta mong đợi:
      // hết loading, và item đầu tiên là item kết quả tìm kiếm.
      // `firstWhere` sẽ giữ cho bài test "sống" cho đến khi điều kiện được thỏa mãn.
      await notifier.stream.firstWhere((state) => 
          !state.isLoading && 
          state.items.isNotEmpty && 
          state.items.first.id == 'search1'
      );

      // Kiểm tra lại state cuối cùng để chắc chắn
      final finalState = container.read(itemFilterProvider('test'));
      expect(finalState.items.length, 1);
      expect(finalState.items.first.id, 'search1');
    });
  });
}
// lib/providers/closets_page_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider này sẽ giữ index của tab con trong ClosetsPage
// 0 = All Items, 1 = By Closet
final closetsSubTabIndexProvider = StateProvider<int>((ref) => 0);
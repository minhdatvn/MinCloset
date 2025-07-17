// lib/helpers/category_helper.dart

import 'package:mincloset/constants/app_options.dart';

// Hàm này được chuyển ra từ notifier, nó sẽ là hàm riêng tư trong file này
String _createLocalizationKey(String base, String value) {
  // Thay thế ký tự không hợp lệ và chuyển thành chữ thường
  return '${base}_${value.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_')}';
}

/// Chuẩn hóa chuỗi danh mục nhận được từ AI thành một định dạng key nhất quán.
///
/// Trả về một chuỗi rỗng '' nếu danh mục không hợp lệ hoặc không xác định.
/// Trả về 'main_key > sub_key' nếu hợp lệ.
String normalizeCategory(String? rawCategory) {
  // 1. Nếu không có danh mục hoặc là trường hợp "Khác > Khác",
  //    trả về chuỗi rỗng để UI hiển thị là "Chưa chọn".
  if (rawCategory == null ||
      rawCategory.trim().isEmpty ||
      rawCategory.toLowerCase() == 'khác > khác' ||
      rawCategory.toLowerCase() == 'other > other') {
    return 'category_other';
  }

  final parts = rawCategory.split(' > ').map((p) => p.trim()).toList();
  final mainCategoryText = parts.first;

  // 2. Tìm key của danh mục chính (VD: "Áo" -> "category_tops")
  final mainCategoryKey = _createLocalizationKey('category', mainCategoryText);

  // 3. Nếu không tìm thấy key cho danh mục chính, coi như không hợp lệ.
  if (!AppOptions.categories.containsKey(mainCategoryKey)) {
    return ''; // Trả về chuỗi rỗng
  }

  // 4. Xử lý danh mục con
  // Nếu chỉ có danh mục chính, hoặc danh mục con là "Other"/"Khác"
  if (parts.length == 1 ||
      parts[1].toLowerCase() == 'other' ||
      parts[1].toLowerCase() == 'khác') {
    final subKey = '${mainCategoryKey}_other';
    // Kiểm tra xem key "other" của danh mục con có tồn tại không
    if (AppOptions.categories[mainCategoryKey]?.contains(subKey) ?? false) {
      return '$mainCategoryKey > $subKey';
    }
    // Nếu không, trả về rỗng
    return '';
  }

  // 5. Xử lý trường hợp có cả danh mục chính và con hợp lệ
  final subCategoryText = parts[1];
  final subCategoryKey = _createLocalizationKey(mainCategoryKey, subCategoryText);

  if (AppOptions.categories[mainCategoryKey]?.contains(subCategoryKey) ?? false) {
    return '$mainCategoryKey > $subCategoryKey';
  }

  // Nếu mọi trường hợp trên đều không khớp, trả về rỗng.
  return '';
}

/// Chuẩn hóa danh sách màu sắc trả về từ AI.
Set<String> normalizeColors(List<dynamic>? rawColors) {
  if (rawColors == null) return {};
  final validColorNames = AppOptions.colors.keys.toSet();
  final selections = <String>{};
  for (final color in rawColors) {
    if (validColorNames.contains(color.toString())) {
      selections.add(color.toString());
    }
  }
  return selections;
}

/// Chuẩn hóa danh sách các lựa chọn đa tuyển (multi-select) như mùa, dịp, chất liệu, họa tiết.
Set<String> normalizeMultiSelect(
    dynamic rawValue, String baseKey, List<String> validOptionKeys) {
  final selections = <String>{};
  if (rawValue == null) return selections;

  final validOptionsSet = validOptionKeys.toSet();
  List<String> valuesToProcess = [];

  // Giá trị từ AI có thể là một chuỗi đơn hoặc một danh sách chuỗi
  if (rawValue is String) {
    valuesToProcess = [rawValue];
  } else if (rawValue is List) {
    valuesToProcess = rawValue.map((e) => e.toString()).toList();
  }

  for (final value in valuesToProcess) {
    // Sửa lỗi: Nhận diện cả 'Other' và 'Khác' để tạo key '..._other'
    if (value.toLowerCase() == 'other' || value.toLowerCase() == 'khác') {
      selections.add('${baseKey}_other');
      continue;
    }

    final optionKey = _createLocalizationKey(baseKey, value);
    if (validOptionsSet.contains(optionKey)) {
      selections.add(optionKey);
    }
  }

  // Nếu không có lựa chọn nào hợp lệ nhưng vẫn có dữ liệu đầu vào,
  // thì mặc định chọn "Khác"
  if (selections.isEmpty && valuesToProcess.isNotEmpty) {
    final otherKey = '${baseKey}_other';
    if (validOptionsSet.contains(otherKey)) {
      selections.add(otherKey);
    }
  }
  return selections;
}
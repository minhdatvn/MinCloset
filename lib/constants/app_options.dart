// file: lib/constants/app_options.dart

// Một lớp nhỏ để định nghĩa một lựa chọn có cả hình ảnh
class OptionWithImage {
  final String name;
  final String imagePath;

  const OptionWithImage({required this.name, required this.imagePath});
}

class AppOptions {
  // Dùng static const để có thể gọi trực tiếp từ tên class mà không cần tạo đối tượng
  // Ví dụ: AppOptions.occasions

  static const List<String> seasons = ['Xuân', 'Hạ', 'Thu', 'Đông'];

  static const Map<String, List<String>> categories = {
    'Áo (Tops)': [
      'Áo thun (T-shirts)', 'Áo dài tay (Long Sleeve)', 'Áo ba lỗ (Sleeveless)',
      'Áo Polo', 'Áo hai dây (Tanks & Camis)', 'Áo crop-top', 'Áo kiểu (Blouses)',
      'Sơ mi (Shirts)', 'Áo nỉ (Sweatshirts)', 'Áo hoodie', 'Áo len (Sweaters)',
    ],
    'Váy & Jumpsuits': [
      'Váy ngày (Day Dresses)', 'Váy thun (T-shirt Dresses)', 'Váy sơ mi (Shirt Dresses)',
      'Váy nỉ (Sweatshirt Dresses)', 'Váy len (Sweater Dresses)', 'Váy khoác (Jacket Dresses)',
      'Váy yếm (Suspender Dresses)', 'Jumpsuits', 'Váy tiệc (Party Dresses)', 'Váy ngắn (Mini Dresses)',
    ],
    // Bạn có thể thêm các danh mục cha khác ở đây, ví dụ: 'Quần (Bottoms)', 'Túi xách (Bags)'...
  };

  static const List<String> colors = [
    'Trắng', 'Đen', 'Xám', 'Đỏ', 'Cam', 'Vàng', 'Xanh lá', 'Xanh dương',
    'Tím', 'Hồng', 'Nâu', 'Beige', 'Bạc', 'Vàng gold'
  ];

  static const List<String> occasions = [
    'Hằng ngày', 'Đi làm', 'Hẹn hò', 'Trang trọng', 'Du lịch',
    'Ở nhà', 'Tiệc tùng', 'Thể thao', 'Đặc biệt', 'Đi học', 'Đi biển', 'Khác'
  ];

  // Danh sách cho các lựa chọn có hình ảnh
  static const List<OptionWithImage> materials = [
    OptionWithImage(name: 'Cotton', imagePath: 'assets/images/materials/cotton.png'),
    OptionWithImage(name: 'Polyester', imagePath: 'assets/images/materials/polyester.png'),
    OptionWithImage(name: 'Nylon', imagePath: 'assets/images/materials/nylon.png'),
    OptionWithImage(name: 'Denim', imagePath: 'assets/images/materials/denim.png'),
    OptionWithImage(name: 'Da (Leather)', imagePath: 'assets/images/materials/leather.png'),
    OptionWithImage(name: 'Len (Wool)', imagePath: 'assets/images/materials/wool.png'),
    // ... Thêm các chất liệu khác của bạn vào đây
  ];

  static const List<OptionWithImage> patterns = [
    OptionWithImage(name: 'Trơn (Solid)', imagePath: 'assets/images/patterns/solid.png'),
    OptionWithImage(name: 'Kẻ sọc (Striped)', imagePath: 'assets/images/patterns/striped.png'),
    OptionWithImage(name: 'Đồ họa (Graphic)', imagePath: 'assets/images/patterns/graphic.png'),
    OptionWithImage(name: 'Chấm bi (Dotted)', imagePath: 'assets/images/patterns/dotted.png'),
    OptionWithImage(name: 'Da thú (Animal)', imagePath: 'assets/images/patterns/animal.png'),
    OptionWithImage(name: 'Hoa (Floral)', imagePath: 'assets/images/patterns/floral.png'),
    // ... Thêm các họa tiết khác của bạn vào đây
  ];
}
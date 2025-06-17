// file: lib/constants/app_options.dart

// Lớp này không thay đổi, vẫn dùng để chứa các lựa chọn có hình ảnh
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionWithImage {
  final String name;
  final String imagePath;

  const OptionWithImage({required this.name, required this.imagePath});
}

class AppOptions {
  static const Map<String, List<String>> categories = {
    'Áo': [
      'Áo thun (T-shirts)', 'Áo dài tay (Long Sleeve)', 'Áo ba lỗ (Sleeveless)',
      'Áo Polo', 'Áo hai dây (Tanks & Camis)', 'Áo crop-top', 'Áo kiểu (Blouses)',
      'Sơ mi (Shirts)', 'Áo nỉ (Sweatshirts)', 'Áo hoodie', 'Áo len (Sweaters)',
    ],
    'Quần': [
      'Quần jeans', 'Quần tây (Trousers)', 'Quần âu (Dress Pants)', 
      'Quần thể thao (Track Pants)', 'Quần legging', 'Quần short'
    ],
    'Váy đầm/Jumpsuit': [
      'Váy ngắn (Mini Skirts)', 'Váy midi (Midi Skirts)', 'Váy dài (Maxi Skirts)',
      'Váy ngày (Day Dresses)', 'Váy thun (T-shirt Dresses)', 'Váy sơ mi (Shirt Dresses)',
      'Váy nỉ (Sweatshirt Dresses)', 'Váy len (Sweater Dresses)', 'Váy khoác (Jacket Dresses)',
      'Váy yếm (Suspender Dresses)', 'Jumpsuits', 'Váy tiệc (Party Dresses)',
    ],
    'Áo khoác': [
      'Áo khoác dáng dài (Coats)', 'Áo măng tô (Trench Coats)', 'Áo lông (Fur Coats)',
      'Áo khoác da cừu (Shearling Coats)', 'Áo blazer', 'Áo khoác (Jackets)',
      'Áo khoác mỏng (Blousons)', 'Varsity Jackets', 'Trucker Jackets', 'Biker Jackets',
      'Áo cardigan', 'Áo hoodie khóa kéo', 'Field Jackets', 'Áo khoác thể thao',
      'Fleece Jackets', 'Áo phao (Puffer/Down Jackets)', 'Áo gile (Vests)'
    ],
    'Giày': [
      'Sneakers', 'Giày lười (Slip Ons)', 'Giày thể thao (Sports Shoes)',
      'Giày đi bộ đường dài (Hiking Shoes)', 'Bốt (Boots)', 'Combat Boots',
      'Ugg Boots', 'Loafers & Mules', 'Giày thuyền (Boat Shoes)', 'Giày bệt (Flat Shoes)',
      'Giày cao gót (Heels)', 'Sandal', 'Sandal cao gót', 'Dép lê (Slides)'
    ],
    'Túi xách': [
      'Túi tote', 'Túi đeo vai (Shoulder)', 'Túi đeo chéo (Crossbody)',
      'Túi đeo hông (Waist)', 'Túi vải (Canvas)', 'Ba lô (Backpacks)',
      'Túi du lịch (Duffel)', 'Ví cầm tay (Clutch)', 'Cặp xách (Briefcases)',
      'Túi dây rút (Drawstring)', 'Vali (Suitcases)'
    ],
    'Mũ': [
      'Mũ lưỡi trai (Cap)', 'Mũ rộng vành (Hats)', 'Mũ len (Beanies)',
      'Mũ nồi (Berets)', 'Mũ phớt (Fedoras)', 'Mũ che nắng (Sun Hats)'
    ],
    'Khác': [], // Để trống danh sách con cho mục "Khác"
  };

  static const Map<String, IconData> categoryIcons = {
    'Áo': FontAwesomeIcons.shirt,
    'Quần': FontAwesomeIcons.personWalking,
    'Váy đầm/Jumpsuit': Icons.woman_outlined,
    'Áo khoác': FontAwesomeIcons.userTie,
    'Giày': FontAwesomeIcons.shoePrints,
    'Túi xách': FontAwesomeIcons.bagShopping,
    'Mũ': FontAwesomeIcons.hatCowboy,
    'Khác': FontAwesomeIcons.tag,
  };
  
  static const List<String> seasons = ['Xuân', 'Hạ', 'Thu', 'Đông'];

  static const Map<String, Color> colors = {
    // Nhóm màu Trung tính
    'Trắng': Color(0xFFFFFFFF),
    'Ngà voi': Color(0xFFFFFFF0),
    'Xám nhạt': Color(0xFFD3D3D3),
    'Xám đậm': Color(0xFFA9A9A9),
    'Đen': Color(0xFF000000),

    // Nhóm màu Vàng & Cam
    'Vàng nhạt': Color(0xFFFFFFE0),
    'Vàng đậm': Color(0xFFFFF176),
    'Vàng nghệ': Color(0xFFFFC107),
    'Cam': Color(0xFFFFA726),
    
    // Nhóm màu Đỏ & Hồng
    'Cam hồng': Color(0xFFFF7F50),
    'Hồng nhạt': Color(0xFFF06292),
    'Hồng đậm': Color(0xFFEC407A),
    'Đỏ': Color.fromARGB(255, 255, 4, 0),
    'Đỏ tía': Color(0xFF880E4F),

    // Nhóm màu Xanh lá
    'Xanh lá mạ': Color(0xFF9CCC65),
    'Xanh thường': Color(0xFF66BB6A),
    'Xanh ô-liu': Color(0xFF808000),
    'Kaki': Color(0xFFC3B091), // Khaki gần với tông nâu/xanh

    // Nhóm màu Xanh dương
    'Xanh ngọc': Color(0xFF26A69A),
    'Lục lam': Color(0xFF26C6DA),
    'Xanh trời': Color(0xFF42A5F5),
    'Xanh biển': Color(0xFF1A237E),

    // Nhóm màu Tím
    'Tím nhạt': Color(0xFFE6E6FA),
    'Tím đậm': Color(0xFFAB47BC),
    'Cánh sen': Color(0xFFD81B60),

    // Nhóm màu Nâu
    'Nâu vàng': Color(0xFFC19A6B),
    'Nâu nhạt': Color(0xFF8D6E63),
    'Nâu đậm': Color(0xFF5D4037),
  };

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
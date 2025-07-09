// lib/widgets/speech_bubble.dart
import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final Widget child; // Widget mascot

  const SpeechBubble({
    super.key,
    required this.text,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- SỬA ĐỔI BẮT ĐẦU TỪ ĐÂY ---
        // Bọc Container bằng ClipOval để cắt thành hình elip
        ClipOval(
          child: Container(
            // Tăng padding để chữ không bị quá sát viền của hình elip
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              // Không cần borderRadius nữa vì đã có ClipOval
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
        // --- KẾT THÚC SỬA ĐỔI ---
        CustomPaint(
          painter: _CurvedArrowPainter(),
          size: const Size(30, 15),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

// CustomPainter để vẽ mũi tên cong
class _CurvedArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // Màu của mũi tên, khớp với màu bong bóng
      ..style = PaintingStyle.fill;

    final path = Path();
    // Bắt đầu vẽ từ góc trái-trên (điểm tiếp xúc với bong bóng)
    path.moveTo(0, 0); 
    // Vẽ đường thẳng trên cùng
    path.lineTo(size.width, 0); 
    // Vẽ đường cong bên PHẢI, đi từ góc phải-trên xuống đỉnh nhọn
    path.quadraticBezierTo(
      size.width * 0.7,  // Điểm kiểm soát X (tạo độ cong)
      size.height * 0.1, // Điểm kiểm soát Y (tạo độ cong)
      size.width / 2,    // Điểm kết thúc X (đỉnh nhọn)
      size.height,       // Điểm kết thúc Y (đỉnh nhọn)
    );
    // Vẽ đường cong bên TRÁI, đi từ đỉnh nhọn ngược lên góc trái-trên
    path.quadraticBezierTo(
      size.width * 0.3,  // Điểm kiểm soát X
      size.height * 0.1, // Điểm kiểm soát Y
      0,                 // Điểm kết thúc X
      0,                 // Điểm kết thúc Y
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) {
    return false;
  }
}
// lib/widgets/gradient_action_card.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GradientActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String imagePath;
  final VoidCallback onTap;

  const GradientActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 120, // Tăng chiều cao để có không gian cho gradient
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // ClipRRect cần bo góc nhỏ hơn border một chút
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Lớp 1: Ảnh nền
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback nếu ảnh lỗi
                    return Container(color: Colors.grey.shade200);
                  },
                ),

                // Lớp 2: Hiệu ứng Gradient chéo
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, // Bắt đầu từ dưới trái
                      end: Alignment.topCenter,   // Kết thúc ở trên phải
                      colors: [
                        Colors.white.withValues(alpha:1.0),  // Bắt đầu: Đậm nhất (không trong suốt)
                        Colors.white.withValues(alpha:0.9), // Bắt đầu mờ dần
                        Colors.white.withValues(alpha:0.5),  // Mờ hơn nữa ở giữa
                        Colors.transparent,             // Kết thúc: Hoàn toàn trong suốt
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                      transform: const GradientRotation(pi / 5),
                    ),
                  ),
                ),

                // Lớp 3: Nội dung (Icon và Text)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end, // Đẩy nội dung xuống dưới
                    children: [
                      Icon(
                        icon,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
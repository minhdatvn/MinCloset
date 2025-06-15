// file: lib/widgets/clothing_sticker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class ClothingSticker extends StatefulWidget {
  final ClothingItem item;

  const ClothingSticker({super.key, required this.item});

  @override
  State<ClothingSticker> createState() => _ClothingStickerState();
}

class _ClothingStickerState extends State<ClothingSticker> {
  // Các biến trạng thái mới
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _position = const Offset(100, 100);

  // Các biến để ghi nhớ trạng thái ban đầu khi bắt đầu thao tác
  double _initialScale = 1.0;
  double _initialRotation = 0.0;


  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        // onScaleStart được gọi khi người dùng bắt đầu thao tác co giãn/xoay
        onScaleStart: (details) {
          // Lưu lại trạng thái ban đầu
          _initialScale = _scale;
          _initialRotation = _rotation;
        },
        // onScaleUpdate được gọi liên tục khi người dùng di chuyển các ngón tay
        onScaleUpdate: (details) {
          setState(() {
            // details.focalPointDelta là khoảng di chuyển của tâm điểm giữa các ngón tay
            // giúp việc kéo-thả khi đang co giãn/xoay mượt hơn
            _position += details.focalPointDelta;
            
            // Cập nhật góc xoay và tỷ lệ
            _rotation = _initialRotation + details.rotation;
            _scale = _initialScale * details.scale;
          });
        },
        // Transform cho phép áp dụng các hiệu ứng biến đổi hình học
        child: Transform(
          alignment: Alignment.center, // Biến đổi từ tâm của widget
          transform: Matrix4.identity()
            ..scale(_scale)      // Áp dụng co giãn
            ..rotateZ(_rotation), // Áp dụng xoay
          child: Container(
            width: 150,
            height: 150,
            child: Image.file(
              File(widget.item.imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
// file: lib/widgets/clothing_sticker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class ClothingSticker extends StatefulWidget {
  final ClothingItem item;
  // Thêm 2 callback mới:
  final VoidCallback onSelect; // Để báo hiệu sticker này đang được chọn
  final VoidCallback onDelete; // Để báo hiệu sticker này cần được xóa

  const ClothingSticker({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  State<ClothingSticker> createState() => _ClothingStickerState();
}

class _ClothingStickerState extends State<ClothingSticker> {
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _position = const Offset(100, 100);

  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: widget.onSelect, // Gọi onSelect khi người dùng nhấn vào
        onScaleStart: (details) {
          widget.onSelect(); // Gọi onSelect cả khi bắt đầu co giãn/xoay
          _initialScale = _scale;
          _initialRotation = _rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            _position += details.focalPointDelta;
            _rotation = _initialRotation + details.rotation;
            _scale = _initialScale * details.scale;
          });
        },
        // Dùng Stack để đặt nút xóa lên trên ảnh
        child: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(_scale)
                ..rotateZ(_rotation),
              child: Container(
                width: 150,
                height: 150,
                child: Image.file(
                  File(widget.item.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Nút xóa được đặt ở góc trên bên phải của sticker
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: widget.onDelete, // Gọi onDelete khi nhấn nút xóa
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
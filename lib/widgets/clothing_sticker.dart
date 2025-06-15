// file: lib/widgets/clothing_sticker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class ClothingSticker extends StatefulWidget {
  final ClothingItem item;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final bool isSelected; // <-- THÊM THUỘC TÍNH NÀY

  const ClothingSticker({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onDelete,
    required this.isSelected, // <-- THÊM VÀO CONSTRUCTOR
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
        onTap: widget.onSelect,
        onScaleStart: (details) {
          widget.onSelect();
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
        child: Stack(
          // Cho phép các phần tử con vẽ ra ngoài khung của Stack
          clipBehavior: Clip.none,
          children: [
            // Ảnh chính và viền xanh khi được chọn
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(_scale)
                ..rotateZ(_rotation),
              child: Container(
                width: 150,
                height: 150,
                // <-- THÊM DECORATION ĐỂ VẼ VIỀN KHI ĐƯỢC CHỌN
                decoration: BoxDecoration(
                  border: widget.isSelected
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Image.file(
                  File(widget.item.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // <-- THÊM ĐIỀU KIỆN ĐỂ CHỈ HIỆN NÚT XÓA KHI ĐƯỢC CHỌN
            if (widget.isSelected)
              Positioned(
                // Đưa nút xóa ra ngoài một chút cho đẹp hơn
                top: -10,
                right: -10,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
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
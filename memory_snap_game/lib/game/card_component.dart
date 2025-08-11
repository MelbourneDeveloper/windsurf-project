import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class CardComponent extends PositionComponent {
  final int value;
  bool isMatched = false;
  bool isRevealed = false;

  CardComponent({
    required Vector2 position,
    required Vector2 size,
    required this.value,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Fill color
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isMatched
          ? Colors.green
          : (isRevealed ? Colors.blue : Colors.grey.shade600);

    // Draw card background
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, fillPaint);
    // Border for better contrast
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.9);
    canvas.drawRect(rect, borderPaint);

    // Draw value when revealed or matched
    if (isRevealed || isMatched) {
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
      textPaint.render(
        canvas,
        value.toString(),
        Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
    }
  }

  void reveal() {
    isRevealed = true;
  }

  void hide() {
    isRevealed = false;
  }

  void match() {
    isMatched = true;
  }
}

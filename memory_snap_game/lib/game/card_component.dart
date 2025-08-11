import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CardComponent extends PositionComponent {
  final int valueId; // used for matching
  final String label; // number or emoji
  bool isMatched = false;
  bool isRevealed = false;
  bool _isAnimating = false;

  CardComponent({
    required Vector2 position,
    required Vector2 size,
    required this.valueId,
    required this.label,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Kid-friendly palette
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isMatched
          ? Colors.lightGreenAccent
          : (isRevealed ? Colors.lightBlueAccent : const Color(0xFFE8EAF6));

    // Draw card background
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, fillPaint);
    // Border for contrast
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.95);
    canvas.drawRRect(rect, borderPaint);

    // Draw value when revealed or matched
    if (isRevealed || isMatched) {
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w800,
        ),
      );
      textPaint.render(
        canvas,
        label,
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

  Future<void> flipToReveal({double halfDuration = 0.12}) async {
    if (isMatched || isRevealed || _isAnimating) return;
    _isAnimating = true;
    // Shrink horizontally then expand, toggling reveal at the midpoint
    final c1 = Completer<void>();
    final e1 = ScaleEffect.to(
      Vector2(0.0, 1.0),
      EffectController(duration: halfDuration, curve: Curves.easeIn),
    )..onComplete = () => c1.complete();
    add(e1);
    await c1.future;
    isRevealed = true;
    final c2 = Completer<void>();
    final e2 = ScaleEffect.to(
      Vector2(1.0, 1.0),
      EffectController(duration: halfDuration, curve: Curves.easeOut),
    )..onComplete = () => c2.complete();
    add(e2);
    await c2.future;
    _isAnimating = false;
  }

  Future<void> flipToHide({double halfDuration = 0.12}) async {
    if (isMatched || !isRevealed || _isAnimating) return;
    _isAnimating = true;
    final c1 = Completer<void>();
    final e1 = ScaleEffect.to(
      Vector2(0.0, 1.0),
      EffectController(duration: halfDuration, curve: Curves.easeIn),
    )..onComplete = () => c1.complete();
    add(e1);
    await c1.future;
    isRevealed = false;
    final c2 = Completer<void>();
    final e2 = ScaleEffect.to(
      Vector2(1.0, 1.0),
      EffectController(duration: halfDuration, curve: Curves.easeOut),
    )..onComplete = () => c2.complete();
    add(e2);
    await c2.future;
    _isAnimating = false;
  }

  Future<void> playMatchPulse() async {
    await add(SequenceEffect([
      ScaleEffect.to(Vector2(1.08, 1.08), EffectController(duration: 0.08, curve: Curves.easeOut)),
      ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.10, curve: Curves.easeIn)),
    ]));
  }
}

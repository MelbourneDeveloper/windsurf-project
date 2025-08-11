import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'game.dart';

class UIComponent extends Component with HasGameReference<MemorySnapGame> {
  late RectangleComponent hudBg;
  late TextComponent scoreText;
  late TextComponent movesText;
  late TextComponent timerText;
  late TimerComponent timer;
  late TextComponent restartText;
  late TextComponent numbersModeText;
  late TextComponent foodModeText;

  @override
  Future<void> onLoad() async {
    // HUD background bar
    hudBg = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(game.size.x, 120),
      anchor: Anchor.topLeft,
      paint: Paint()..color = const Color(0xFF5C6BC0), // indigo 400
    );

    final textPaint = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 32.0,
      ),
    );

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
      textRenderer: textPaint,
    );

    movesText = TextComponent(
      text: 'Moves: 0',
      position: Vector2(20, 60),
      textRenderer: textPaint,
    );

    timerText = TextComponent(
      text: 'Time: 00:00',
      position: Vector2(20, 100),
      textRenderer: textPaint,
    );

    timer = TimerComponent(
      period: 1.0,
      repeat: true,
      onTick: () {
        final minutes = (game.gameTime / 60).floor().toString().padLeft(2, '0');
        final seconds = (game.gameTime % 60).floor().toString().padLeft(2, '0');
        timerText.text = 'Time: $minutes:$seconds';
      },
    );

    restartText = TextComponent(
      text: 'Restart',
      position: Vector2(game.size.x - 120, 20),
      textRenderer: textPaint,
    );

    final smallText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
      ),
    );

    numbersModeText = TextComponent(
      text: 'Numbers',
      position: Vector2(game.size.x - 260, 70),
      textRenderer: smallText,
    );

    foodModeText = TextComponent(
      text: 'Food',
      position: Vector2(game.size.x - 140, 70),
      textRenderer: smallText,
    );

    addAll([hudBg, scoreText, movesText, timerText, timer, numbersModeText, foodModeText, restartText]);
  }

  void updateScore(int score) {
    scoreText.text = 'Score: $score';
  }

  void updateMoves(int moves) {
    movesText.text = 'Moves: $moves';
  }

  void reset() {
    game.score = 0;
    game.moves = 0;
    game.gameTime = 0;
    updateScore(0);
    updateMoves(0);
    timerText.text = 'Time: 00:00';
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    hudBg.size = Vector2(size.x, 120);
    // Reposition right-aligned labels
    restartText.position = Vector2(size.x - 120, 20);
    numbersModeText.position = Vector2(size.x - 260, 70);
    foodModeText.position = Vector2(size.x - 140, 70);
  }
}

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'game.dart';

class UIComponent extends Component with HasGameReference<MemorySnapGame> {
  late TextComponent scoreText;
  late TextComponent movesText;
  late TextComponent timerText;
  late TimerComponent timer;
  late TextComponent restartText;

  @override
  Future<void> onLoad() async {
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
      position: Vector2(game.size.x - 100, 20),
      textRenderer: textPaint,
    );

    addAll([scoreText, movesText, timerText, timer, restartText]);
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
}

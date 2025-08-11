import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:memory_snap_game/game/card_component.dart';
import 'ui_component.dart';
import 'dart:ui';
import 'dart:async';

enum GameMode { numbers, food }

class MemorySnapGame extends FlameGame with TapDetector {
  double gameTime = 0;
  late UIComponent uiComponent;
  bool _initialized = false;
  GameMode mode = GameMode.food;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    uiComponent = UIComponent();
    add(uiComponent);
    // Defer initializeGame until we know the game size
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTime += dt;
  }
  late List<CardComponent> cards;
  int score = 0;
  int moves = 0;
  CardComponent? firstCard;
  CardComponent? secondCard;
  bool canTap = true;


  void initializeGame() {
    // Avoid initializing before we have a valid size
    if (size.x <= 0 || size.y <= 0) return;
    // Clear existing cards if any
    children.whereType<CardComponent>().toList().forEach(remove);

    final grid = 4;
    // Reserve some vertical space for UI at the top
    const double topPadding = 140;
    const double margin = 12; // spacing between cards and edges
    final double usableWidth = (size.x - (grid + 1) * margin).clamp(0, size.x);
    final double usableHeight = (size.y - topPadding - (grid + 1) * margin).clamp(0, size.y);
    final double cellW = usableWidth / grid;
    final double cellH = usableHeight / grid;
    final cardSize = Vector2(cellW, cellH);
    
    // Create pairs of cards
    final pairs = _buildPairs(grid);

    cards = [];
    for (int i = 0; i < pairs.length; i++) {
      final x = (i % grid).toDouble();
      final y = (i ~/ grid).toDouble();
      final pos = Vector2(
        margin + x * (cellW + margin),
        topPadding + margin + y * (cellH + margin),
      );
      final p = pairs[i];
      cards.add(CardComponent(
        position: pos,
        size: cardSize,
        valueId: p.$1,
        label: p.$2,
      ));
    }

    addAll(cards);
    _initialized = true;
  }

  // Returns a shuffled list of pairs (valueId, label)
  List<(int, String)> _buildPairs(int grid) {
    final count = grid * grid ~/ 2;
    List<(int, String)> base;
    switch (mode) {
      case GameMode.numbers:
        base = List.generate(count, (i) => (i + 1, '${i + 1}'));
        break;
      case GameMode.food:
        const foods = ['🍎','🍌','🍇','🍓','🍕','🍦','🍪','🥕','🍉','🍒','🥑','🌽'];
        base = List.generate(count, (i) => (i, foods[i % foods.length]));
        break;
    }
    final all = [...base, ...base];
    all.shuffle();
    return all;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (!_initialized && canvasSize.x > 0 && canvasSize.y > 0) {
      initializeGame();
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E);

  @override
  void onTapDown(TapDownInfo info) {
    if (!canTap) return;
    // Use widget coordinates (no camera transforms in this game)
    final Vector2 touchPosition = info.eventPosition.widget;

    // Handle HUD buttons first
    if (uiComponent.restartText.containsPoint(touchPosition)) {
      _restart();
      return;
    }
    if (uiComponent.numbersModeText.containsPoint(touchPosition)) {
      if (mode != GameMode.numbers) {
        mode = GameMode.numbers;
        uiComponent.updateModeHighlight(mode);
        _restart();
      }
      return;
    }
    if (uiComponent.foodModeText.containsPoint(touchPosition)) {
      if (mode != GameMode.food) {
        mode = GameMode.food;
        uiComponent.updateModeHighlight(mode);
        _restart();
      }
      return;
    }

    CardComponent? tappedCard;
    for (final card in cards) {
      if (!card.isMatched && card.containsPoint(touchPosition)) {
        tappedCard = card;
        break;
      }
    }
    if (tappedCard == null) return;

    // Animate flip
    tappedCard.flipToReveal();
    moves++;
    uiComponent.updateMoves(moves);

    if (firstCard == null) {
      firstCard = tappedCard;
    } else if (secondCard == null && firstCard != tappedCard) {
      secondCard = tappedCard;
      checkMatch();
    }
  }

  void checkMatch() {
    canTap = false;
    if (firstCard!.valueId == secondCard!.valueId) {
      score += 10;
      uiComponent.updateScore(score);
      firstCard!.match();
      secondCard!.match();
      firstCard!.playMatchPulse();
      secondCard!.playMatchPulse();
      firstCard = null;
      secondCard = null;
      canTap = true;
      checkGameComplete();
    } else {
      // Not a match, flip back after delay with animation
      Future.delayed(const Duration(milliseconds: 500), () {
        firstCard?.flipToHide();
        secondCard?.flipToHide();
        firstCard = null;
        secondCard = null;
        canTap = true;
      });
    }
  }

  void checkGameComplete() {
    if (cards.every((card) => card.isMatched)) {
      // Game complete logic
      print('Game complete! Score: $score, Moves: $moves');
      uiComponent.reset();
    }
  }

  void _restart() {
    score = 0;
    moves = 0;
    gameTime = 0;
    uiComponent.updateScore(0);
    uiComponent.updateMoves(0);
    initializeGame();
  }
}

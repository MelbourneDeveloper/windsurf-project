import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:memory_snap_game/game/card_component.dart';
import 'ui_component.dart';
import 'dart:ui';

class MemorySnapGame extends FlameGame with TapDetector {
  double gameTime = 0;
  late UIComponent uiComponent;
  bool _initialized = false;

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
    final double topPadding = 140;
    final double usableHeight = (size.y - topPadding).clamp(0, size.y);
    final cardSize = Vector2(size.x / grid, usableHeight / grid);
    
    // Create pairs of cards
    final cardValues = List.generate(grid * grid ~/ 2, (index) => index + 1);
    final allCards = [...cardValues, ...cardValues];
    allCards.shuffle();

    cards = [];
    for (int i = 0; i < allCards.length; i++) {
      final x = (i % grid).toDouble();
      final y = (i ~/ grid).toDouble();
      final pos = Vector2(x * cardSize.x, topPadding + y * cardSize.y);
      cards.add(CardComponent(
        position: pos,
        size: cardSize,
        value: allCards[i],
      ));
    }

    addAll(cards);
    _initialized = true;
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

    CardComponent? tappedCard;
    for (final card in cards) {
      if (!card.isMatched && card.containsPoint(touchPosition)) {
        tappedCard = card;
        break;
      }
    }
    if (tappedCard == null) return;

    tappedCard.reveal();
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
    if (firstCard!.value == secondCard!.value) {
      score += 10;
    uiComponent.updateScore(score);
      firstCard!.match();
      secondCard!.match();
      firstCard = null;
      secondCard = null;
      canTap = true;
      checkGameComplete();
    } else {
      Future.delayed(Duration(milliseconds: 1000), () {
        firstCard!.hide();
        secondCard!.hide();
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
}

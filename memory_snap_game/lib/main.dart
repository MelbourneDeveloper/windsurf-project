import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/game.dart';

void main() {
  runApp(const MemorySnapApp());
}

class MemorySnapApp extends StatelessWidget {
  const MemorySnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Snap Game',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GameWidget(game: MemorySnapGame()),
      ),
    );
  }
}


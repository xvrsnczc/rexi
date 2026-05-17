import 'package:flutter/material.dart';

import '../../domain/game_model.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, this.onTap});

  final GameModel game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(game.title),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}

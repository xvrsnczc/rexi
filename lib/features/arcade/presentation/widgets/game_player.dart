import 'package:flutter/material.dart';

/// Contenedor del jugador / WebView del juego (placeholder).
class GamePlayer extends StatelessWidget {
  const GamePlayer({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black87,
        child: Center(
          child: Text(
            'Juego $gameId',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

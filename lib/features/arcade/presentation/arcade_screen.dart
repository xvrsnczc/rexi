import 'package:flutter/material.dart';

import '../data/arcade_repository.dart';
import '../domain/game_model.dart';
import 'widgets/game_card.dart';
import 'widgets/game_player.dart';

/// REXI Arcade — lista de juegos; al tocar se abre la vista de juego.
class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  void _openGame(BuildContext context, GameModel game) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: Text(game.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: GamePlayer(gameId: game.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REXI Arcade')),
      body: FutureBuilder(
        future: ArcadeRepository.instance.games(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final games = snap.data ?? [];
          if (games.isEmpty) {
            return const Center(child: Text('No hay juegos disponibles por ahora.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final game = games[i];
              return GameCard(
                game: game,
                onTap: () => _openGame(context, game),
              );
            },
          );
        },
      ),
    );
  }
}

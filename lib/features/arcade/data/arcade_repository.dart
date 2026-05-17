import '../domain/game_model.dart';

/// Listado de juegos; reemplazar por API cuando exista backend.
class ArcadeRepository {
  const ArcadeRepository();

  static const ArcadeRepository instance = ArcadeRepository();

  Future<List<GameModel>> games() async {
    await Future<void>.delayed(Duration.zero);
    return const [
      GameModel(id: 'g1', title: 'Runner neuronal'),
      GameModel(id: 'g2', title: 'Puzle Arcova'),
      GameModel(id: 'g3', title: 'Space IA retro'),
    ];
  }
}

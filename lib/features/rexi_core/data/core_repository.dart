import '../domain/knowledge_model.dart';

class CoreRepository {
  const CoreRepository();

  static const CoreRepository instance = CoreRepository();

  Future<List<KnowledgeModel>> articles() async {
    await Future<void>.delayed(Duration.zero);
    return const [
      KnowledgeModel(id: 'k1', title: 'Introducción a REXI Core'),
      KnowledgeModel(id: 'k2', title: 'Buenas prácticas de la comunidad'),
      KnowledgeModel(id: 'k3', title: 'Actualizaciones y novedades'),
    ];
  }
}

import 'package:flutter/material.dart';

import '../../domain/knowledge_model.dart';

class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({super.key, required this.item, this.onTap});

  final KnowledgeModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title),
        onTap: onTap,
      ),
    );
  }
}

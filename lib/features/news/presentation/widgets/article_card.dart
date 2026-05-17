import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(summary),
        onTap: onTap,
      ),
    );
  }
}

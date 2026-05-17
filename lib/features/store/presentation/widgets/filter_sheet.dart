import 'package:flutter/material.dart';

/// Bottom sheet de filtros de tienda.
Future<void> showStoreFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Filtros — enlazar con `catalog_filters` o estado local.'),
      ),
    ),
  );
}

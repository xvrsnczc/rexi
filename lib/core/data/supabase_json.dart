/// Normaliza respuestas lista de PostgREST.
List<Map<String, dynamic>> supabaseAsMapList(dynamic response) {
  final list = response as List<dynamic>;
  return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

double asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int asInt(dynamic v, [int fallback = 1]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

String? pickStr(Map<String, dynamic> row, List<String> keys) {
  for (final k in keys) {
    if (row.containsKey(k) && row[k] != null) {
      return row[k].toString();
    }
  }
  for (final e in row.entries) {
    for (final k in keys) {
      if (e.key.toLowerCase() == k.toLowerCase() && e.value != null) {
        return e.value.toString();
      }
    }
  }
  return null;
}

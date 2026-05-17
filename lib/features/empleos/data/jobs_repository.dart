import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/job_model.dart';

/// Listado desde [SupabaseTables.empleos]. Si la tabla no existe o RLS bloquea, devuelve [].
class JobsRepository {
  JobsRepository._(this._client);

  final SupabaseClient _client;

  static JobsRepository? _instance;

  static JobsRepository get instance {
    _instance ??= JobsRepository._(Supabase.instance.client);
    return _instance!;
  }

  Future<List<JobModel>> listings() async {
    try {
      final rows = supabaseAsMapList(
        await _client.from(SupabaseTables.empleos).select('*').limit(50),
      );
      return rows
          .map((r) {
            final id = pickStr(r, ['id']) ?? '';
            final title = pickStr(r, [
                  'Título',
                  'titulo',
                  'title',
                  'nombre',
                  'Nombre',
                ]) ??
                'Vacante';
            final company = pickStr(r, [
                  'Empresa',
                  'empresa',
                  'company',
                  'company_name',
                  'organizacion',
                  'Organización',
                ]) ??
                '—';
            return JobModel(id: id, title: title, company: company);
          })
          .where((j) => j.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

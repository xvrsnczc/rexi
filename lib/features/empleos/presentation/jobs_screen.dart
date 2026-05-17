import 'package:flutter/material.dart';

import '../../../core/config/supabase_tables.dart';
import '../data/jobs_repository.dart';
import '../domain/job_model.dart';
import 'job_detail_screen.dart';
import 'widgets/job_card.dart';

/// REXI Empleos — listado vía [JobsRepository].
class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REXI Empleos')),
      body: FutureBuilder<List<JobModel>>(
        future: JobsRepository.instance.listings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snap.data ?? [];
          if (jobs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No hay vacantes o la tabla «${SupabaseTables.empleos}» no está disponible.\n'
                  'Crea la tabla en Supabase o ajusta el nombre en supabase_tables.dart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final job = jobs[i];
              return JobCard(
                job: job,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => JobDetailScreen(job: job),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../domain/job_model.dart';
import 'widgets/apply_button.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              job.company,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ref. ${job.id}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ApplyButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Postulación: enlaza aquí tu flujo (formulario o URL).'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

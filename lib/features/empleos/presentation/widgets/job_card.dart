import 'package:flutter/material.dart';

import '../../domain/job_model.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final JobModel job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.company),
        onTap: onTap,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../patient/providers/patient_providers.dart';

class AllDoctorsScreen extends ConsumerWidget {
  final String doctorType;
  const AllDoctorsScreen({super.key,required this.doctorType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$doctorType Doctors'),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2))),
        error: (error, _) => Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: $error', style: const TextStyle(color: Colors.red, fontSize: 16)),
          ),
        ),
        data: (doctors) {
          final matchingDoctors = doctors
              .where((doctor) => doctor.category == doctorType)
              .toList()
            ..sort((a, b) => b.averageRatings.compareTo(a.averageRatings));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchingDoctors.length,
            itemBuilder: (context, index) {
              final doctor = matchingDoctors[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: doctor.profileImageUrl.isNotEmpty
                        ? NetworkImage(doctor.profileImageUrl)
                        : null,
                    child: doctor.profileImageUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
                  ),
                  title: Text(
                    doctor.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.hospital,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rating: ${doctor.averageRatings.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Fee: ${doctor.consultationFee}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
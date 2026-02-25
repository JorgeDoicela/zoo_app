import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/animal_providers.dart';
import 'widgets/add_care_log_sheet.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsyncValue = ref.watch(animalsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Animal'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: animalsAsyncValue.when(
        data: (animals) {
          final animal = animals.firstWhere(
            (a) => a.id == animalId,
            orElse: () => throw Exception('Animal no encontrado'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  animal.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                Text(animal.species, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 40),
                
                // Generación de QR automático basado en el ID del animal
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        QrImageView(
                          // En la vida real aquí pondrías la URL de tu app p. ej. https://tu-zoo.web.app/public/$animal.id
                          data: 'https://tu-zoo.web.app/public/${animal.id}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 10),
                        const Text('Código de Visitante', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('Recinto'),
                  subtitle: Text(animal.enclosureId),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: const Text('Último Chequeo'),
                  subtitle: Text(animal.lastCheckup.toString().split(' ')[0]),
                ),
                const SizedBox(height: 30),
                const Divider(),
                Text(
                  'Bitácora de Cuidados',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCareLogs(context, ref, animalId),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => AddCareLogSheet(animalId: animalId),
          );
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }

  Widget _buildCareLogs(BuildContext context, WidgetRef ref, String animalId) {
    final logsAsync = ref.watch(careLogsProvider(animalId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No hay registros en la bitácora aún.', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            IconData icon;
            Color iconColor;

            switch (log.type) {
              case 'Alimentación':
                icon = Icons.restaurant;
                iconColor = Colors.orange;
                break;
              case 'Medicina':
                icon = Icons.medical_services;
                iconColor = Colors.red;
                break;
              default:
                icon = Icons.visibility;
                iconColor = Colors.blue;
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor),
                ),
                title: Text(log.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.note),
                    const SizedBox(height: 4),
                    Text(
                      '${log.date.toString().substring(0, 16)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

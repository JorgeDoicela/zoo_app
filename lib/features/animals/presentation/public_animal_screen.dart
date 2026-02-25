import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/animal_providers.dart';

class PublicAnimalScreen extends ConsumerWidget {
  final String animalId;

  const PublicAnimalScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar el stream de todos los animales (o podríamos crear uno específico por ID)
    final animalsAsyncValue = ref.watch(animalsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre a nuestro amigo'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: animalsAsyncValue.when(
        data: (animals) {
          try {
            final animal = animals.firstWhere((a) => a.id == animalId);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.pets, size: 80, color: Colors.orange.shade300),
                  const SizedBox(height: 20),
                  Text(
                    '¡Hola! Soy ${animal.name}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Especie: ${animal.species}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Dato Curioso: \n\n¡Me encanta vivir en este zoo! Recuerda no alimentarme, mis cuidadores saben exactamente qué dieta necesito para estar sano y fuerte.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Recinto: ${animal.enclosureId}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          } catch (e) {
            return const Center(child: Text('Animal no encontrado.'));
          }
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

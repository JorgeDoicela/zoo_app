import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'widgets/add_animal_sheet.dart';
import '../providers/animal_providers.dart';
import '../../auth/providers/auth_provider.dart';

class AnimalsScreen extends ConsumerWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsyncValue = ref.watch(animalsStreamProvider);
    final userAsync = ref.watch(currentUserDataProvider);
    final isAdmin = userAsync.value?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Animales'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () => context.push('/inventory'),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: animalsAsyncValue.when(
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(
              child: Text('No hay animales registrados aún.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Hero(
                    tag: animal.id,
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: animal.imageUrl != null 
                        ? CachedNetworkImageProvider(animal.imageUrl!) 
                        : null,
                      child: animal.imageUrl == null 
                        ? const Icon(Icons.pets, color: Colors.green) 
                        : null,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          animal.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      if (DateTime.now().difference(animal.lastCheckup).inDays > 7)
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    ],
                  ),
                  subtitle: Text('${animal.species} • Recinto: ${animal.enclosureId}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.go('/animals/details/${animal.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => _showAddAnimalSheet(context),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  void _showAddAnimalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddAnimalSheet(),
    );
  }
}

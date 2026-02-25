import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/animal_model.dart';
import '../../providers/animal_providers.dart';

class AddAnimalSheet extends ConsumerStatefulWidget {
  const AddAnimalSheet({super.key});

  @override
  ConsumerState<AddAnimalSheet> createState() => _AddAnimalSheetState();
}

class _AddAnimalSheetState extends ConsumerState<AddAnimalSheet> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _enclosureController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Nuevo: Controlador para URL
  bool _isSaving = false;

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _speciesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena los campos obligatorios')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final id = const Uuid().v4();
      
      // Creamos el animal directamente con la URL proporcionada
      final newAnimal = Animal(
        id: id,
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        enclosureId: _enclosureController.text.trim().isEmpty 
            ? 'General' 
            : _enclosureController.text.trim(),
        lastCheckup: DateTime.now(),
        imageUrl: _imageUrlController.text.trim().isEmpty 
            ? null 
            : _imageUrlController.text.trim(),
      );

      await ref.read(animalRepositoryProvider).addAnimal(newAnimal);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registrar Nuevo Animal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de la Imagen (Opcional)',
                hintText: 'https://ejemplo.com/lion.jpg',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Animal *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Especie *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _enclosureController,
              decoration: const InputDecoration(
                labelText: 'ID del Recinto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GUARDAR EN ZOO'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

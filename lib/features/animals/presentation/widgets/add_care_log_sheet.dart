import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/animal_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/care_log_model.dart';
import 'package:uuid/uuid.dart';

class AddCareLogSheet extends ConsumerStatefulWidget {
  final String animalId;

  const AddCareLogSheet({super.key, required this.animalId});

  @override
  ConsumerState<AddCareLogSheet> createState() => _AddCareLogSheetState();
}

class _AddCareLogSheetState extends ConsumerState<AddCareLogSheet> {
  final _formKey = GlobalKey<FormState>();
  String _note = '';
  String _type = 'Observación';
  bool _isLoading = false;

  final List<String> _types = ['Alimentación', 'Medicina', 'Observación'];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final uid = ref.read(authStateProvider).value?.uid ?? 'unknown';
        
        final newLog = CareLog(
          id: const Uuid().v4(),
          animalId: widget.animalId,
          note: _note,
          caregiverId: uid, 
          date: DateTime.now(),
          type: _type,
        );

        await ref.read(animalRepositoryProvider).addCareLog(widget.animalId, newLog);
        
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nueva Entrada (Bitácora)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de Entrada',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _types.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nota detallada',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              onSaved: (val) => _note = val!,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar Entrada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

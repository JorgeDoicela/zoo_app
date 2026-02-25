import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/inventory_providers.dart';
import '../../domain/inventory_model.dart';

class AddInventoryItemSheet extends ConsumerStatefulWidget {
  const AddInventoryItemSheet({super.key});

  @override
  ConsumerState<AddInventoryItemSheet> createState() => _AddInventoryItemSheetState();
}

class _AddInventoryItemSheetState extends ConsumerState<AddInventoryItemSheet> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = 'Alimentos';
  int _quantity = 0;
  String _unit = 'kg';
  int _minThreshold = 0;
  bool _isLoading = false;

  final List<String> _categories = ['Alimentos', 'Medicinas', 'Suministros'];
  final List<String> _units = ['kg', 'litros', 'unidades'];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final newItem = InventoryItem(
          id: const Uuid().v4(),
          name: _name,
          category: _category,
          quantity: _quantity,
          unit: _unit,
          minThreshold: _minThreshold,
        );

        await ref.read(inventoryRepositoryProvider).addItem(newItem);
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nuevo Artículo de Inventario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre del Artículo', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Cantidad Inicial', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (val) => int.tryParse(val ?? '') == null ? 'Número inválido' : null,
                      onSaved: (val) => _quantity = int.parse(val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(labelText: 'Unidad', border: OutlineInputBorder()),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) => setState(() => _unit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Alerta Umbral Mínimo', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => int.tryParse(val ?? '') == null ? 'Número inválido' : null,
                onSaved: (val) => _minThreshold = int.parse(val!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar Artículo'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

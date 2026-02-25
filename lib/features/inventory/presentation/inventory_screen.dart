import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_providers.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/add_inventory_item_sheet.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final userAsync = ref.watch(currentUserDataProvider);
    final isAdmin = userAsync.value?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Inventario vacío.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isLow = item.quantity <= item.minThreshold;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isLow ? Colors.red.shade300 : Colors.transparent,
                    width: isLow ? 2 : 0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.category} • Min: ${item.minThreshold}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.red : Colors.green,
                        ),
                      ),
                      if (isAdmin)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              ref.read(inventoryRepositoryProvider).deleteItem(item.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Editar (Proximamente)')),
                            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddInventoryItemSheet(),
          );
        },
        backgroundColor: Colors.brown.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}

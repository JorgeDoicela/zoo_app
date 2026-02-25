import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/inventory_repository.dart';
import '../domain/inventory_model.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final localDb = ref.watch(databaseServiceProvider);
  return InventoryRepository(localDb);
});

final inventoryProvider = StreamProvider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getItems();
});

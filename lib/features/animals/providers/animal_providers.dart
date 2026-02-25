import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/animal_repository.dart';
import '../domain/animal_model.dart';
import '../domain/care_log_model.dart';

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  final localDb = ref.watch(databaseServiceProvider);
  return AnimalRepository(localDb);
});

// StreamProvider para obtener la lista de animales en tiempo real en la UI
final animalsStreamProvider = StreamProvider<List<Animal>>((ref) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.getAnimals();
});

// StreamProvider para obtener la bitácora de un animal
final careLogsProvider = StreamProvider.family<List<CareLog>, String>((ref, animalId) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.getCareLogs(animalId);
});

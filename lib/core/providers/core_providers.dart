import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

import '../services/biometric_service.dart';
import '../services/database_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

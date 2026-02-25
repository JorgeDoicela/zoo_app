import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_local_storage/flutter_secure_local_storage.dart';

class StorageService {
  // 1. FLUTTER_SECURE_STORAGE: Implementa cifrado a nivel de hardware/sistema operativo.
  // Se usa para guardar datos pequeños como el UID del usuario o tokens de acceso.
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ), // Cifrado extra en Android
  );

  // 2. FLUTTER_SECURE_LOCAL_STORAGE: Crea un archivo cifrado en el sistema de archivos local.
  // Sirve como redundancia o respaldo de la sesión para asegurar la persistencia offline.
  // IMPORTANTE: En Web no se puede inicializar (LateInitializationError).
  final _localSecureStorage = FlutterSecureLocalStorage();

  // Guarda la sesión de forma duplicada para máxima durabilidad de los datos
  Future<void> saveSession(String uid) async {
    // Almacena en el sistema de claves seguro del dispositivo
    await _secureStorage.write(key: 'user_uid', value: uid);

    // Respalda en el archivo persistente local (excepto en Web)
    if (!kIsWeb) {
      await _localSecureStorage.write('session_data', uid);
    }
  }

  // Recupera la sesión intentando ambas capas (seguridad por redundancia)
  Future<String?> getSession() async {
    // Primero intentamos con el almacenamiento seguro rápido
    String? uid = await _secureStorage.read(key: 'user_uid');

    // Si no está ahí (ej: corrupción de caché), buscamos en el archivo local de respaldo
    if (uid == null && !kIsWeb) {
      uid = await _localSecureStorage.read('session_data');
    }

    return uid;
  }

  // Limpia ambas capas al cerrar sesión para no dejar rastros de datos sensibles
  Future<void> clearSession() async {
    // Borra todas las llaves del Secure Storage
    await _secureStorage.deleteAll();

    // Elimina físicamente el archivo de respaldo local
    if (!kIsWeb) {
      await _localSecureStorage.remove('session_data');
    }
  }
}

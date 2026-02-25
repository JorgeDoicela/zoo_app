import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_local_storage/flutter_secure_local_storage.dart';

class StorageService {
  // 1. FlutterSecureStorage para pares clave-valor (ej: tokens)
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // 2. FlutterSecureLocalStorage para archivos de datos locales cifrados
  // Nota: No se debe usar en Web ya que causa LateInitializationError
  final _localSecureStorage = FlutterSecureLocalStorage();

  // Guardar el ID del usuario tras el login
  Future<void> saveSession(String uid) async {
    await _secureStorage.write(key: 'user_uid', value: uid);
    if (!kIsWeb) {
      await _localSecureStorage.write('session_data', uid);
    }
  }

  // Leer la sesión para el auto-login
  Future<String?> getSession() async {
    // Intentamos leer de la capa principal
    String? uid = await _secureStorage.read(key: 'user_uid');
    
    // Si falla y no es web, intentamos con la capa local segura
    if (uid == null && !kIsWeb) {
      uid = await _localSecureStorage.read('session_data');
    }
    
    return uid;
  }

  // Borrar al cerrar sesión
  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    if (!kIsWeb) {
      await _localSecureStorage.remove('session_data');
    }
  }
}

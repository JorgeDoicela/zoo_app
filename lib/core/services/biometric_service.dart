import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Verificar si el dispositivo soporta biometría
  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  // Verificar si el usuario tiene huellas o FaceID configurado
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  // Ejecutar el escaneo
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder al Zoo Management Pro',
      );
    } on PlatformException catch (e) {
      print('Error en biometría: $e');
      return false;
    }
  }
}

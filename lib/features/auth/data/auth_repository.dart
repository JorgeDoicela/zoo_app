import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/storage_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login con Firebase
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      User? user = result.user;

      if (user != null) {
        // PERSISTENCIA PROFESIONAL: Guardamos el UID de forma segura
        await _storage.saveSession(user.uid);

        // AUTO-CREACIÓN DE PERFIL (Para pruebas y primer inicio)
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'role': 'admin', // Asignamos admin por defecto para que puedas probar
            'name': user.email?.split('@')[0] ?? 'Usuario',
          });
        }
      }
      return user;
    } catch (e) {
      rethrow; // Manejar el error en la UI
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.clearSession();
  }

  // Obtener datos del usuario (Rol, Nombre)
  Stream<UserModel?> getUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// StreamProvider para obtener el rol y datos del usuario logueado en tiempo real
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return authRepo.getUserData(user.uid);
      } else {
        return Stream.value(null);
      }
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

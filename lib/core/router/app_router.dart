import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/animals/presentation/animals_screen.dart';
import '../../features/animals/presentation/public_animal_screen.dart';
import '../../features/animals/presentation/scanner_screen.dart';
import '../../features/animals/presentation/animal_detail_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/inventory/presentation/inventory_screen.dart';

// Helper para convertir un Stream en un Listenable para GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/animals',
    // ESTO ES CLAVE: El router se refresca cuando cambia el estado de Firebase
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/animals',
        builder: (context, state) => const AnimalsScreen(),
        routes: [
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AnimalDetailScreen(animalId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/public/:id',
        builder: (context, state) => PublicAnimalScreen(
          animalId: state.pathParameters['id']!,
        ),
      ),
    ],
    
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isPublic = state.matchedLocation.startsWith('/public');

      // Las rutas públicas siempre están permitidas
      if (isPublic) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/animals';
      
      return null;
    },
  );
});

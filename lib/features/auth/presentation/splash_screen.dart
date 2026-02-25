import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final storage = ref.read(storageServiceProvider);
    final bioService = ref.read(biometricServiceProvider);
    final session = await storage.getSession();

    if (!mounted) return;

    if (session != null) {
      // Si hay sesión, pedimos biometría por seguridad (GRATIS)
      final isAuthenticated = await bioService.authenticate();
      
      if (!mounted) return;
      
      if (isAuthenticated) {
        context.go('/animals'); // Ir a la lista de animales
      } else {
        // Si cancela la biometría, lo mandamos a login por seguridad
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Zoo App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

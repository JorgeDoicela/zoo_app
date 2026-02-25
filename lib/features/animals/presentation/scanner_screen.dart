import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Animal'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              String raw = barcode.rawValue!;
              
              // Si es un QR tradicional con link, extraemos el ID del final
              String animalId = raw;
              if (raw.contains('/public/')) {
                animalId = raw.split('/public/').last;
              }

              // Navegación profesional usando el ID detectado a la vista de empleado
              context.go('/animals/details/$animalId');
              break; // Salimos del bucle una vez detectado
            }
          }
        },
      ),
      // Overlay para guiar al usuario
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        label: const Text('Cancelar'),
        icon: const Icon(Icons.close),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

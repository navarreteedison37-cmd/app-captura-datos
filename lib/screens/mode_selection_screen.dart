import 'package:flutter/material.dart';
import '../services/modo_service.dart';
import '../services/template_service.dart';
import 'home_screen.dart';

/// Esta pantalla aparece UNA SOLA VEZ (la primera vez que se abre la app).
/// Una vez elegido el modo, la app recuerda la eleccion y busca
/// automaticamente la plantilla Word correspondiente cada vez que se
/// genera un documento.
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  Future<void> _elegir(BuildContext context, ModoTrabajo modo) async {
    await ModoService().guardarModo(modo);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 72),
              const SizedBox(height: 16),
              const Text(
                '¿Qué tipo de documento vas a trabajar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta pregunta solo aparece una vez. La app recordará tu elección.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _elegir(context, ModoTrabajo.inspeccionLaboral),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Text('Inspección Laboral'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _elegir(context, ModoTrabajo.controlIngresos),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Text('Control de Ingresos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

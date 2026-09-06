import 'package:flutter/material.dart';
import 'services/modo_service.dart';
import 'services/template_service.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Captura de Datos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const PantallaInicial(),
    );
  }
}

/// Decide, al abrir la app, si ya existe un modo guardado.
/// - Si NO existe -> muestra la pregunta (una sola vez).
/// - Si YA existe -> va directo a la pantalla principal.
class PantallaInicial extends StatelessWidget {
  const PantallaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ModoTrabajo?>(
      future: ModoService().obtenerModoGuardado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) {
          return const ModeSelectionScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

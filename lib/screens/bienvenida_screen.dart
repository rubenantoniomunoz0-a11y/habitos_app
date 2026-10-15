import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import 'principal_screen.dart';

// Pantalla de bienvenida. Solo se muestra la primera vez que se abre
// la app (cuando todavía no hay nombre guardado).
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  // Controladores para leer lo que escribe el usuario en los TextField.
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();

  // Servicio que centraliza el acceso a SharedPreferences.
  final PreferenciasService _prefs = PreferenciasService();

  // Liberamos los controladores cuando se cierra la pantalla.
  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  // Lee los datos, los valida y los guarda en SharedPreferences.
  // Después navega a la pantalla principal (pushReplacement para
  // que no se pueda volver atrás con el botón del móvil).
  Future<void> _empezar() async {
    final String nombre = _nombreController.text.trim();
    final int objetivo = int.tryParse(_objetivoController.text.trim()) ?? 0;

    // Validación: si falta el nombre o el objetivo no es un número
    // mayor que 0, mostramos un aviso y no seguimos.
    if (nombre.isEmpty || objetivo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre y un objetivo valido')),
      );
      return;
    }

    await _prefs.guardarNombre(nombre);
    await _prefs.guardarObjetivo(objetivo);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PrincipalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a HabitosApp')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cuentame un poco sobre ti',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Campo para el nombre del usuario.
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Campo para el objetivo diario. Solo acepta números.
            TextField(
              controller: _objetivoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo diario (n habitos)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _empezar,
              child: const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}
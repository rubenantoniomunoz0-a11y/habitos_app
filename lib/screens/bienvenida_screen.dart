import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import 'principal_screen.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();

  final PreferenciasService _prefs = PreferenciasService();

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _empezar() async {
    final String nombre = _nombreController.text.trim();
    final int objetivo = int.tryParse(_objetivoController.text.trim()) ?? 0;

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
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
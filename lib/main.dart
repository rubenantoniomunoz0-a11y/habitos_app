import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';
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

}

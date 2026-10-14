import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final PreferenciasService _prefs = PreferenciasService();

  bool _temaOscuro = false;
  bool _ocultarCompletados = false;
  double _tamanoLetra = 1.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final tema = await _prefs.leerTemaOscuro();
    final ocultar = await _prefs.leerOcultarCompletados();
    final tamano = await _prefs.leerTamanoLetra();

    if (!mounted) return;
    setState(() {
      _temaOscuro = tema;
      _ocultarCompletados = ocultar;
      _tamanoLetra = tamano;
      _cargando = false;
    });
    Future<void> _cambiarTema(bool valor) async {
      setState(() => _temaOscuro = valor);
      await _prefs.guardarTemaOscuro(valor);
    }

    Future<void> _cambiarOcultar(bool valor) async {
      setState(() => _ocultarCompletados = valor);
      await _prefs.guardarOcultarCompletados(valor);
    }

    Future<void> _cambiarTamano(double valor) async {
      setState(() => _tamanoLetra = valor);
      await _prefs.guardarTamanoLetra(valor);
    }

    Future<void> _borrarDatos() async {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Borrar todos los datos'),
            content: const Text(
              'Esto borrara todos tus datos y la app volvera a empezar desde cero. Continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Borrar todo'),
              ),
            ],
          );
        },
      );

      if (confirmado != true) return;

      await _prefs.borrarTodo();

      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
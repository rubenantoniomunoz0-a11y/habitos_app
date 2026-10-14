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
  }
}
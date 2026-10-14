import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/loading_widget.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final PreferenciasService _prefs = PreferenciasService();

  List<Habito> _habitos = [];
  int _aperturas = 0;
  DateTime? _ultimaApertura;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final habitos = await _prefs.leerHabitos();
    final aperturas = await _prefs.leerAperturas();
    final ultima = await _prefs.leerUltimaApertura();

    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _aperturas = aperturas;
      _ultimaApertura = ultima;
      _cargando = false;
    });
  }
}
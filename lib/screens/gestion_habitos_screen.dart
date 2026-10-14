import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';

class GestionHabitosScreen extends StatefulWidget {
  const GestionHabitosScreen({super.key});

  @override
  State<GestionHabitosScreen> createState() => _GestionHabitosScreenState();
}

class _GestionHabitosScreenState extends State<GestionHabitosScreen> {
  final PreferenciasService _prefs = PreferenciasService();

  List<Habito> _habitos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final habitos = await _prefs.leerHabitos();
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });
  }
}
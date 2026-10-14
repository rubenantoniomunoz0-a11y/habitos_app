import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferences_service.dart';
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

  String _fechaAString(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  int _rachaActual(Habito habito) {
    int racha = 0;
    DateTime dia = DateTime.now();
    while (habito.fechascompletado.contains(_fechaAString(dia))) {
      racha++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return racha;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const LoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Uso de la app',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Veces abierta: $_aperturas'),
          Text(
            'Ultima apertura: ${_ultimaApertura != null ? _ultimaApertura.toString().substring(0, 19) : "Sin datos"}',
          ),
          const Divider(height: 32),
          const Text(
            'Tus habitos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_habitos.isEmpty)
            const Text('No hay habitos todavia')
          else
            ..._habitos.map((h) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Color(h.color)),
                  title: Text(h.nombre),
                  subtitle: Text(
                    'Racha actual: ${_rachaActual(h)} dias   |   Total: ${h.fechascompletado.length} dias',
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
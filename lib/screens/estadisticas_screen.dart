import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferences_service.dart';
import '../widgets/loading_widget.dart';

// Pantalla de estadísticas: uso de la app y progreso de cada hábito.
// Solo lee datos, no modifica nada.
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  // Servicio que centraliza el acceso a SharedPreferences.
  final PreferenciasService _prefs = PreferenciasService();

  // Datos que se leen al abrir la pantalla.
  List<Habito> _habitos = [];
  int _aperturas = 0;
  DateTime? _ultimaApertura;

  // Mientras se leen los datos guardados.
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Leo los hábitos y las estadísticas de uso de SharedPreferences.
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

  // Convierte un DateTime a "YYYY-MM-DD", que es el formato con el
  // que se guardan las fechas en el modelo Habito.
  String _fechaAString(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  // Cuenta los días seguidos que se ha completado el hábito hasta hoy.
  // Empieza en hoy y va restando días mientras sigan apareciendo en
  // la lista de fechas completadas.
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
    // Mientras se leen los datos, mostramos el indicador de carga.
    if (_cargando) {
      return const LoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Uso de la app ----
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
          // ---- Racha y total por hábito ----
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
                  // La racha se calcula con _rachaActual y el total
                  // es directamente el número de fechas completadas.
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
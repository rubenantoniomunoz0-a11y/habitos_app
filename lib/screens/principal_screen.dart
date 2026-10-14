import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferences_service.dart';
import '../widgets/habito_tile.dart';
import '../widgets/loading_widget.dart';
import 'estadisticas_screen.dart';
import 'ajustes_screen.dart';
import 'gestion_habitos_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final PreferenciasService _prefs = PreferenciasService();

  String _nombre = '';
  int _objetivo = 0;
  List<Habito> _habitos = [];
  bool _ocultarCompletados = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final nombre = await _prefs.leerNombre();
    final objetivo = await _prefs.leerObjetivo();
    final habitos = await _prefs.leerHabitos();
    final ocultar = await _prefs.leerOcultarCompletados();

    if (!mounted) return;
    setState(() {
      _nombre = nombre ?? '';
      _objetivo = objetivo;
      _habitos = habitos;
      _ocultarCompletados = ocultar;
      _cargando = false;
    });
  }

  String _fechaHoy() {
    final hoy = DateTime.now();
    final mes = hoy.month.toString().padLeft(2, '0');
    final dia = hoy.day.toString().padLeft(2, '0');
    return '${hoy.year}-$mes-$dia';
  }

  Future<void> _toggleHabito(int index) async {
    final habito = _habitos[index];
    final clave = _fechaHoy();

    final nuevasFechas = List<String>.from(habito.fechascompletado);
    if (nuevasFechas.contains(clave)) {
      nuevasFechas.remove(clave);
    } else {
      nuevasFechas.add(clave);
    }

    final actualizado = Habito(
      id: habito.id,
      nombre: habito.nombre,
      color: habito.color,
      fechascompletado: nuevasFechas,
    );

    setState(() {
      _habitos[index] = actualizado;
    });

    await _prefs.guardarHabitos(_habitos);
  }

  int _completadosHoy() {
    final clave = _fechaHoy();
    return _habitos
        .where((h) => h.fechascompletado.contains(clave))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const LoadingWidget();
    }

    final clave = _fechaHoy();
    final habitosVisibles = _ocultarCompletados
        ? _habitos.where((h) => !h.fechascompletado.contains(clave)).toList()
        : _habitos;

    final completados = _completadosHoy();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitosApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadisticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AjustesScreen()),
              );
              _cargarDatos();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_nombre',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$completados de $_objetivo habitos'),
            const Divider(height: 32),
            Expanded(
              child: habitosVisibles.isEmpty
                  ? const Center(child: Text('No hay habitos todavia'))
                  : ListView.builder(
                itemCount: habitosVisibles.length,
                itemBuilder: (context, i) {
                  final habito = habitosVisibles[i];
                  final indexReal = _habitos.indexOf(habito);
                  return HabitoTile(
                    habito: habito,
                    completadoHoy:
                    habito.fechascompletado.contains(clave),
                    onCambio: (_) => _toggleHabito(indexReal),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Gestionar habitos',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GestionHabitosScreen()),
          );
          _cargarDatos();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
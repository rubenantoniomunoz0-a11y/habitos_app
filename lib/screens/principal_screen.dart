import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferences_service.dart';
import '../widgets/habito_tile.dart';
import '../widgets/loading_widget.dart';
import 'estadisticas_screen.dart';
import 'ajustes_screen.dart';
import 'gestion_habitos_screen.dart';

// Pantalla principal: saludo, progreso del día y lista de hábitos.
// Desde aquí se navega a las demás pantallas.
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  // Servicio que centraliza el acceso a SharedPreferences.
  final PreferenciasService _prefs = PreferenciasService();

  // Datos que se leen al abrir la pantalla.
  String _nombre = '';
  int _objetivo = 0;
  List<Habito> _habitos = [];
  bool _ocultarCompletados = false;

  // Mientras se leen los datos guardados.
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Leo de SharedPreferences el nombre, el objetivo, los hábitos y
  // el ajuste de ocultar completados.
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

  // Fecha de hoy en formato "YYYY-MM-DD", que es como se guardan
  // las fechas completadas en el modelo Habito.
  String _fechaHoy() {
    final hoy = DateTime.now();
    final mes = hoy.month.toString().padLeft(2, '0');
    final dia = hoy.day.toString().padLeft(2, '0');
    return '${hoy.year}-$mes-$dia';
  }

  // Marca o desmarca el hábito de hoy y guarda los cambios.
  Future<void> _toggleHabito(int index) async {
    final habito = _habitos[index];
    final clave = _fechaHoy();

    // Copiamos la lista de fechas y añadimos o quitamos la de hoy.
    final nuevasFechas = List<String>.from(habito.fechascompletado);
    if (nuevasFechas.contains(clave)) {
      nuevasFechas.remove(clave);
    } else {
      nuevasFechas.add(clave);
    }

    // Los campos del modelo son final, así que creamos uno nuevo
    // con las fechas actualizadas y sustituimos el original.
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

  // Cuenta cuántos hábitos están marcados hoy (para el progreso).
  int _completadosHoy() {
    final clave = _fechaHoy();
    return _habitos
        .where((h) => h.fechascompletado.contains(clave))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se leen los datos, mostramos el indicador de carga.
    if (_cargando) {
      return const LoadingWidget();
    }

    final clave = _fechaHoy();

    // Si el usuario ha activado "ocultar completados", filtramos los
    // hábitos ya marcados hoy.
    final habitosVisibles = _ocultarCompletados
        ? _habitos.where((h) => !h.fechascompletado.contains(clave)).toList()
        : _habitos;

    final completados = _completadosHoy();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitosApp'),
        actions: [
          // Abre la pantalla de estadísticas.
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
          // Abre ajustes. Al volver, recargamos los datos porque el
          // tema o el ajuste de ocultar pueden haber cambiado.
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
            // Saludo personalizado.
            Text(
              'Hola, $_nombre',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Progreso del día.
            Text('$completados de $_objetivo habitos'),
            const Divider(height: 32),
            // Lista de hábitos con su casilla.
            Expanded(
              child: habitosVisibles.isEmpty
                  ? const Center(child: Text('No hay habitos todavia'))
                  : ListView.builder(
                itemCount: habitosVisibles.length,
                itemBuilder: (context, i) {
                  final habito = habitosVisibles[i];
                  // Si hay hábitos ocultos, el index de la lista visible
                  // no coincide con el de _habitos: buscamos el real.
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
      // Botón flotante para ir a gestionar los hábitos. Al volver,
      // recargamos porque pueden haberse creado o borrado.
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
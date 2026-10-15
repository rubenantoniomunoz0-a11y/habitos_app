import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

// Pantalla de ajustes: tema, tamaño de letra y borrado de datos.
// Todos los cambios se guardan al momento en SharedPreferences.
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  // Servicio que centraliza el acceso a SharedPreferences.
  final PreferenciasService _prefs = PreferenciasService();

  // Ajustes que se leen al abrir la pantalla.
  bool _temaOscuro = false;
  bool _ocultarCompletados = false;
  double _tamanoLetra = 1.0;

  // Mientras se leen los ajustes guardados.
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Leo los ajustes guardados nada más entrar en la pantalla.
  Future<void> _cargar() async {
    final tema = await _prefs.leerTemaOscuro();
    final ocultar = await _prefs.leerOcultarCompletados();
    final tamano = await _prefs.leerTamanoLetra();

    // Si la pantalla se ha cerrado antes de terminar, no hacemos setState.
    if (!mounted) return;
    setState(() {
      _temaOscuro = tema;
      _ocultarCompletados = ocultar;
      _tamanoLetra = tamano;
      _cargando = false;
    });
  }

  // Cada ajuste se guarda al momento en SharedPreferences, así al volver
  // a la pantalla principal ya se aplica el cambio.

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

  // Pide confirmación y borra todo lo guardado. Al volver a la pantalla
  // principal, la app verá que ya no hay nombre y mostrará la bienvenida
  // otra vez, como si fuera la primera ejecución.
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

    // Si el usuario cancela, no hacemos nada.
    if (confirmado != true) return;

    await _prefs.borrarTodo();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se leen los ajustes, mostramos un indicador de carga.
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Interruptor para activar el tema oscuro.
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: _temaOscuro,
            onChanged: _cambiarTema,
          ),
          // Interruptor para ocultar los hábitos ya completados hoy
          // en la pantalla principal.
          SwitchListTile(
            title: const Text('Ocultar habitos completados hoy'),
            value: _ocultarCompletados,
            onChanged: _cambiarOcultar,
          ),
          const SizedBox(height: 16),
          // Control deslizante para el tamaño de letra.
          const Text('Tamano de letra'),
          Slider(
            value: _tamanoLetra,
            min: 0.8,
            max: 1.6,
            divisions: 8,
            label: _tamanoLetra.toStringAsFixed(1),
            onChanged: _cambiarTamano,
          ),
          const Divider(height: 32),
          // Botón para dejar la app como recién instalada.
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _borrarDatos,
            child: const Text(
              'Borrar todos los datos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
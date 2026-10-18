import 'package:flutter/material.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/principal_screen.dart';
import 'services/preferences_service.dart';
import 'widgets/loading_widget.dart';

void main() {
  runApp(const HabitosApp());
}

// Widget raíz de la app. Como necesito leer SharedPreferences antes
// de decidir qué pantalla mostrar, tiene que ser Stateful.
class HabitosApp extends StatefulWidget {
  const HabitosApp({super.key});

  @override
  State<HabitosApp> createState() => _HabitosAppState();
}

class _HabitosAppState extends State<HabitosApp> {
  // Servicio que centraliza el acceso a SharedPreferences.
  final PreferenciasService _prefs = PreferenciasService();

  // Estados que se leen al arrancar.
  bool _cargando = true;
  bool _primeraVez = true;
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  // Al arrancar la app: registro la apertura y leo los ajustes.
  Future<void> _inicializar() async {
    await _prefs.registrarApertura();

    final primera = await _prefs.esPrimeraEjecucion();
    final tema = await _prefs.leerTemaOscuro();
    final tamano = await _prefs.leerTamanoLetra();

    if (!mounted) return;
    setState(() {
      _primeraVez = primera;
      _temaOscuro = tema;
      _tamanoLetra = tamano;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se leen los datos, mostramos un indicador de carga.
    if (_cargando) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoadingWidget(),
      );
    }

    return MaterialApp(
      title: 'HabitosApp',
      debugShowCheckedModeBanner: false,
      // Aplica el tema claro u oscuro según el ajuste guardado.
      themeMode: _temaOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // MediaQuery para cambiar el tamaño de letra en toda la app.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_tamanoLetra),
          ),
          child: child!,
        );
      },
      // Si es la primera vez que se abre, muestra Bienvenida.
      // Si no, va directo a Principal.
      home: _primeraVez
          ? const BienvenidaScreen()
          : const PrincipalScreen(),
    );
  }
}
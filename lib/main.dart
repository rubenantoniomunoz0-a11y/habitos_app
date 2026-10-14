import 'package:flutter/material.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/principal_screen.dart';
import 'services/preferencias_service.dart';
import 'widgets/loading_widget.dart';

void main() {
  runApp(const HabitosApp());
}

class HabitosApp extends StatefulWidget {
  const HabitosApp({super.key});

  @override
  State<HabitosApp> createState() => _HabitosAppState();
}

class _HabitosAppState extends State<HabitosApp> {
  final PreferenciasService _prefs = PreferenciasService();

  bool _cargando = true;
  bool _primeraVez = true;
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

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
    if (_cargando) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoadingWidget(),
      );
    }

    return MaterialApp(
      title: 'HabitosApp',
      debugShowCheckedModeBanner: false,
      themeMode: _temaOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_tamanoLetra),
          ),
          child: child!,
        );
      },
      home: _primeraVez
          ? const BienvenidaScreen()
          : const PrincipalScreen(),
    );
  }
}
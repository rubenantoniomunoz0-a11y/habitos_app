import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habito.dart';
import 'claves_prefs.dart';

// Las pantallas llaman a estos métodos, nunca a SharedPreferences directamente.
class PreferenciasService {

  // --- USUARIO ---

  Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ClavesPrefs.nombre, nombre);
  }

  // Devuelve null si es la primera vez que se abre la app.
  Future<String?> leerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ClavesPrefs.nombre);
  }

  Future<void> guardarObjetivo(int objetivo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ClavesPrefs.objetivo, objetivo);
  }

  Future<int> leerObjetivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ClavesPrefs.objetivo) ?? 3;
  }

  Future<bool> esPrimeraEjecucion() async {
    final nombre = await leerNombre();
    return nombre == null;
  }

  // --- HÁBITOS ---

  // SharedPreferences no guarda listas de objetos, así que paso la lista
  // a un String en formato JSON con jsonEncode.
  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      habitos.map((h) => h.toJson()).toList(),
    );
    await prefs.setString(ClavesPrefs.habitos, jsonString);
  }

  // Leo el JSON y lo vuelvo a convertir en lista de objetos Habito.
  Future<List<Habito>> leerHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(ClavesPrefs.habitos);

    // Primera vez: no hay nada guardado.
    if (jsonString == null) return [];

    final List<dynamic> lista = jsonDecode(jsonString);
    return lista
        .map((item) => Habito.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // --- ESTADÍSTICAS ---

  Future<void> registrarApertura() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Contador (int)
    final int actual = prefs.getInt(ClavesPrefs.aperturas) ?? 0;
    await prefs.setInt(ClavesPrefs.aperturas, actual + 1);

    // 2. Última apertura (String ISO)
    final String ahora = DateTime.now().toIso8601String();
    await prefs.setString(ClavesPrefs.ultimaApertura, ahora);

    // 3. Historial (List<String>). Guardo solo las 10 últimas fechas
    // para que no crezca sin control.
    final List<String> historial =
        prefs.getStringList(ClavesPrefs.historialAperturas) ?? [];
    historial.add(ahora);
    final List<String> recortado = historial.length > 10
        ? historial.sublist(historial.length - 10)
        : historial;
    await prefs.setStringList(ClavesPrefs.historialAperturas, recortado);
  }

  Future<int> leerAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ClavesPrefs.aperturas) ?? 0;
  }

  // La fecha está guardada como String ISO, la convierto a DateTime.
  Future<DateTime?> leerUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    final String? iso = prefs.getString(ClavesPrefs.ultimaApertura);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<List<String>> leerHistorialAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(ClavesPrefs.historialAperturas) ?? [];
  }

  // --- AJUSTES ---

  Future<void> guardarTemaOscuro(bool oscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ClavesPrefs.temaOscuro, oscuro);
  }

  Future<bool> leerTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ClavesPrefs.temaOscuro) ?? false;
  }

  Future<void> guardarOcultarCompletados(bool ocultar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ClavesPrefs.ocultarCompletados, ocultar);
  }

  Future<bool> leerOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ClavesPrefs.ocultarCompletados) ?? false;
  }

  Future<void> guardarTamanoLetra(double tamano) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(ClavesPrefs.tamanoLetra, tamano);
  }

  Future<double> leerTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(ClavesPrefs.tamanoLetra) ?? 1.0;
  }

  // --- BORRAR----

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
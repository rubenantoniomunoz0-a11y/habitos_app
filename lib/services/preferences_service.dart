import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habito.dart';
import 'claves_prefs.dart';

class PreferenciasService {
  Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ClavesPrefs.nombre, nombre);
  }

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

  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      habitos.map((h) => h.toJson()).toList(),
    );
    await prefs.setString(ClavesPrefs.habitos, jsonString);
  }

  Future<List<Habito>> leerHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(ClavesPrefs.habitos);

    if (jsonString == null) return [];

    final List<dynamic> lista = jsonDecode(jsonString);
    return lista
        .map((item) => Habito.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> registrarApertura() async {
    final prefs = await SharedPreferences.getInstance();

    final int actual = prefs.getInt(ClavesPrefs.aperturas) ?? 0;
    await prefs.setInt(ClavesPrefs.aperturas, actual + 1);

    final String ahora = DateTime.now().toIso8601String();
    await prefs.setString(ClavesPrefs.ultimaApertura, ahora);

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

  Future<DateTime?> leerUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    final String? iso = prefs.getString(ClavesPrefs.ultimaApertura);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<List<String>> leerHistorialAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(ClavesPrefs.historialAperturas) ?? [];
  }

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

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
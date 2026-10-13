import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habito.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  // Inicializa la instancia de SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- USO DE LOS 5 TIPOS DE DATOS DE SHAREDPREFERENCES ---

  // 1. STRING: Guarda el nombre del usuario
  static Future<bool> setNombreUsuario(String nombre) async {
    return await _prefs.setString('usuario_nombre', nombre);
  }

  static String getNombreUsuario() {
    return _prefs.getString('usuario_nombre') ?? 'Usuario';
  }

  // 2. INT: Guarda la meta diaria de hábitos a cumplir
  static Future<bool> setMetaDiaria(int meta) async {
    return await _prefs.setInt('meta_diaria', meta);
  }

  static int getMetaDiaria() {
    return _prefs.getInt('meta_diaria') ?? 3;
  }

  // 3. DOUBLE: Guarda el porcentaje de racha o progreso alcanzado
  static Future<bool> setProgresoHistoria(double porcentaje) async {
    return await _prefs.setDouble('progreso_historia', porcentaje);
  }

  static double getProgresoHistoria() {
    return _prefs.getDouble('progreso_historia') ?? 0.0;
  }

  // 4. BOOL: Guarda la preferencia de tema oscuro / claro
  static Future<bool> setModoOscuro(bool valor) async {
    return await _prefs.setBool('modo_oscuro', valor);
  }

  static bool getModoOscuro() {
    return _prefs.getBool('modo_oscuro') ?? false;
  }

  // 5. LIST<STRING>: Guarda la lista de hábitos serializada en JSON
  static Future<bool> guardarHabitos(List<Habito> habitos) async {
    List<String> habitosJson = habitos
        .map((habito) => jsonEncode(habito.toJson()))
        .toList();
    return await _prefs.setStringList('lista_habitos', habitosJson);
  }

  static List<Habito> obtenerHabitos() {
    List<String>? habitosJson = _prefs.getStringList('lista_habitos');
    if (habitosJson == null) return [];

    return habitosJson
        .map((item) => Habito.fromJson(jsonDecode(item)))
        .toList();
  }
}
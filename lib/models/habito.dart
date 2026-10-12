
class Habito {
  // ---- Campos ----
  final String id;
  final String nombre;
  final int color;
  final List<String> fechascompletado;

  // ---- Constructor normal ----
  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    required this.fechascompletado,
  });

  // ---- Constructor desde JSON ----
  // Recibe un Map y va leyendo cada campo.
  Habito.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        nombre = json['nombre'] as String,
        color = json['color'] as int,
        fechascompletado = List<String>.from(json['fechascompletado']);

  // ---- Método a JSON ----
  // Devuelve un Map con los mismos nombres de campos.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechascompletado': fechascompletado,
    };
  }
}
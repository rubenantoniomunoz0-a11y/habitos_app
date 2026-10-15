/// Modelo de un hábito. Se guarda serializado en JSON dentro de
/// SharedPreferences, ya que esta solo admite tipos básicos.
class Habito {
  final String id;
  final String nombre;
  final int color;
  final List<String> fechascompletado;

  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    required this.fechascompletado,
  });

  // Construye un Habito a partir del Map que devuelve jsonDecode.
  Habito.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        nombre = json['nombre'] as String,
        color = json['color'] as int,
        fechascompletado = List<String>.from(json['fechascompletado']);

  // Convierte el objeto a Map para poder guardarlo con jsonEncode.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechascompletado': fechascompletado,
    };
  }
}